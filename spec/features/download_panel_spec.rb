# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'download panel', :js do
  include PurlFixtures

  let(:request) do
    Embed::Request.new(
      { url: 'http://purl.stanford.edu/abc123' },
      controller
    )
  end

  describe 'hide download?' do
    before do
      stub_purl_xml_response_with_fixture(geo_purl_public)
    end

    it 'when selected should hide the button' do
      visit_iframe_response('abc123', hide_download: true)
      expect(page).not_to have_css('button[data-sul-embed-toggle="sul-embed-download-panel"]')
    end

    it 'when not selected should display the button' do
      visit_iframe_response('abc123')
      expect(page).to have_css('button[data-sul-embed-toggle="sul-embed-download-panel"]')
    end
  end
end
