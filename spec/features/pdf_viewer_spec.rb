# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PDF Viewer' do
  include PurlFixtures
  let(:purl) { pdf_document_purl }

  before do
    stub_purl_response_with_fixture(purl)
    visit_iframe_response
  end

  it 'renders the PDF viewer for documents' do
    expect(page).to have_css('.sul-embed-body embed')
  end
end
