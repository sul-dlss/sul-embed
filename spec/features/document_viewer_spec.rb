# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PDF Viewer', :js do
  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
    visit iframe_path(url: "#{Settings.purl_url}/ignored", canvas_index:)
  end

  let(:canvas_index) { nil }

  context 'when world visible' do
    let(:purl) { build(:purl, :document, download: 'world') }

    it 'renders the PDF viewer for documents' do
      expect(page).to have_css('.sul-embed-pdf')
    end

    context 'with a canvas index' do
      let(:canvas_index) { 3 }

      it 'opens the PDF to the corresponding one-based page' do
        expect(page).to have_css('.sul-embed-pdf[data-pdf-page-value="4"]')

        page.execute_script <<~JAVASCRIPT
          window.dispatchEvent(new CustomEvent("auth-success", {
            detail: {
              fileUri: "https://stacks.stanford.edu/file/xk848ts1579/Forecasting_Effective_Digital_Libs.pdf"
            }
          }))
        JAVASCRIPT

        object = page.find('object', visible: :all)
        expect(object[:data]).to match(
          %r{\Ahttps://stacks\.stanford\.edu/file/xk848ts1579/Forecasting_Effective_Digital_Libs\.pdf\?time=\d+#page=4\z}
        )
      end
    end
  end
end
