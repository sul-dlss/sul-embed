# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PDF Viewer', :js do
  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
    visit_iframe_response
  end

  context 'when world visible' do
    let(:purl) { build(:purl, :public, :document) }

    it 'renders the PDF viewer for documents' do
      expect(page).to have_css('.sul-embed-pdf')
    end

    it 'has working panels' do
      expect(page).to have_css('.sul-embed-metadata-panel', visible: :all)
      within '.sul-embed-footer-toolbar' do
        first('button').click
      end
      expect(page).to have_css('.sul-embed-metadata-panel', visible: :visible)
    end
  end

  context 'when no download' do
    let(:purl) { build(:purl, :document_no_download) }

    it 'renders the PDF viewer for documents with restriction message' do
      expect(page).to have_css('.sul-embed-pdf')
      expect(page).to have_content('This item cannot be accessed online')
    end
  end

  context 'when embargoed' do
    let(:purl) { build(:purl, :embargoed, :document) }

    it 'renders the PDF viewer for documents with embargo restriction message' do
      expect(page).to have_css('.sul-embed-pdf')
      expect(page).to have_content('This item is embargoed until 21-Dec-2053.')
    end
  end
end
