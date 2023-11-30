# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PDF Viewer', :js do
  let(:purl) { build(:purl, :document) }

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
    visit_iframe_response
  end

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
