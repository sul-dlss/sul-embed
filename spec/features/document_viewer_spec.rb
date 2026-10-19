# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PDF Viewer', :js do
  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
    visit iframe_path(url: "#{Settings.purl_url}/ignored", **query)
  end

  let(:query) { {} }

  context 'when world visible' do
    let(:purl) { build(:purl, :document, download: 'world') }

    it 'renders the PDF viewer for documents' do
      expect(page).to have_css('.sul-embed-pdf')
    end

    context 'with a canvas index' do
      let(:query) { { canvas_index: 3 } }

      it 'opens the PDF to the corresponding one-based page' do
        expect(page).to have_css('.sul-embed-pdf[data-pdf-page-value="4"]')

        page.execute_script <<~JAVASCRIPT
          window.dispatchEvent(new CustomEvent("auth-success", {
            detail: {
              fileUri: "https://stacks.stanford.edu/file/bc123df4567/Title%20of%20the%20PDF.pdf"
            }
          }))
        JAVASCRIPT

        object = page.find('object', visible: :all)
        expect(object[:data]).to match(
          %r{\Ahttps://stacks\.stanford\.edu/file/bc123df4567/Title%20of%20the%20PDF\.pdf\?time=\d+#page=4\z}
        )
      end
    end
  end

  context 'with several PDFs' do
    let(:purl) do
      build(:purl, :document, download: 'world', contents: issues.map do |number|
        build(:resource, :document, files: [issue(number)])
      end)
    end
    let(:issues) { 1..2 }

    def issue(number)
      build(:resource_file, :document, :world_downloadable, filename: "issue-#{number}.pdf", label: "Issue #{number}")
    end

    def issue_url(number)
      "https://stacks.stanford.edu/file/bc123df4567/issue-#{number}.pdf"
    end

    # Stands in for the manifest the viewer would fetch from purl, which paints each PDF on a canvas
    def receive_manifest
      canvases = issues.map do |number|
        { items: [{ items: [{ motivation: 'painting', body: { id: issue_url(number), format: 'application/pdf' } }] }] }
      end
      manifest = { items: canvases }.to_json
      page.execute_script <<~JAVASCRIPT
        window.dispatchEvent(new CustomEvent("iiif-manifest-received", { detail: #{manifest} }))
      JAVASCRIPT
    end

    def displayed_pdf
      page.find('.sul-embed-pdf object', visible: :all)[:data]
    end

    it 'opens on the first PDF' do
      expect(page).to have_css('.file-thumb.active', text: 'Issue 1', visible: :all)

      receive_manifest
      expect(displayed_pdf).to match(/\A#{Regexp.escape(issue_url(1))}\?time=\d+\z/)
    end

    context 'when a filename is requested' do
      let(:query) { { filename: 'issue-2.pdf' } }

      it 'opens on that PDF rather than the first one' do
        expect(page).to have_css('.file-thumb.active', text: 'Issue 2', visible: :all)
        expect(page).to have_css('.file-thumb.active', count: 1, visible: :all)

        receive_manifest
        expect(displayed_pdf).to match(/\A#{Regexp.escape(issue_url(2))}\?time=\d+\z/)
      end
    end

    context 'when the filename is not on the object' do
      let(:query) { { filename: 'nope.pdf' } }

      it 'falls back to the first PDF' do
        expect(page).to have_css('.file-thumb.active', text: 'Issue 1', visible: :all)

        receive_manifest
        expect(displayed_pdf).to match(/\A#{Regexp.escape(issue_url(1))}\?time=\d+\z/)
      end
    end

    context 'when a filename and page are requested' do
      let(:query) { { filename: 'issue-2.pdf', page: '3' } }

      it 'opens that PDF to the page, but opens the others at the start' do
        receive_manifest
        expect(displayed_pdf).to match(/\A#{Regexp.escape(issue_url(2))}\?time=\d+#page=3\z/)

        find('.file-thumb', text: 'Issue 1', visible: :all).execute_script('this.click()')
        expect(page).to have_css(%(.sul-embed-pdf object[data^="#{issue_url(1)}"]), visible: :all)
        expect(displayed_pdf).to match(/\A#{Regexp.escape(issue_url(1))}\?time=\d+\z/)
      end
    end

    context 'when the requested PDF is far down a long content list' do
      let(:issues) { 1..30 }
      let(:query) { { filename: 'issue-30.pdf' } }

      def active_item_in_view?
        page.evaluate_script <<~JAVASCRIPT
          (() => {
            const item = document.querySelector("#content-list [role=tab].active")
            const list = item.closest(".left-drawer-content").getBoundingClientRect()
            const { top, bottom } = item.getBoundingClientRect()
            return top >= list.top && bottom <= list.bottom
          })()
        JAVASCRIPT
      end

      it 'scrolls the content list to show it' do
        within 'aside.open' do
          expect(page).to have_css('.file-thumb.active', text: 'Issue 30')
        end

        page.document.synchronize do
          raise Capybara::ExpectationNotMet, 'the active item is scrolled out of view' unless active_item_in_view?
        end
      end
    end
  end
end
