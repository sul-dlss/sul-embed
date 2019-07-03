# frozen_string_literal: true

require 'rails_helper'

describe 'PDF Viewer', js: true do
  include PURLFixtures
  let(:purl) { pdf_document_purl }

  before do
    stub_purl_response_with_fixture(purl)
    visit_iframe_response
  end

  it 'renders the PDF viewer for documents' do
    expect(page).to have_css('.sul-embed-pdf #pdf-viewer')
  end

  it 'renders a loading spinner' do
    expect(page).to have_css('.loading-spinner')
  end
end
