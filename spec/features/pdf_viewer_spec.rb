# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PDF Viewer', :js do
  include PurlFixtures
  let(:purl) { pdf_document_purl }

  before do
    stub_purl_xml_response_with_fixture(purl)
    visit_iframe_response
  end

  it 'renders the PDF viewer for documents' do
    expect(page).to have_css('.sul-embed-pdf #pdf-viewer')
  end

  it 'renders a loading spinner' do
    expect(page).to have_css('.loading-spinner')
  end

  it 'has working panels' do
    expect(page).to have_css('.sul-embed-metadata-panel', visible: :all)
    within '.sul-embed-footer-toolbar' do
      first('button').click
    end
    expect(page).to have_css('.sul-embed-metadata-panel', visible: :visible)
  end
end
