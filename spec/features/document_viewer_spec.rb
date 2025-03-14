# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PDF Viewer', :js do
  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
    visit_iframe_response
  end

  context 'when world visible' do
    let(:purl) { build(:purl, :document, download: 'world') }

    it 'renders the PDF viewer for documents' do
      expect(page).to have_css('.sul-embed-pdf')
    end
  end
end
