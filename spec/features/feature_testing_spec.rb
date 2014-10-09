require 'rails_helper'

describe 'feature testing of viewers', js: true do
  include PURLFixtures
  describe 'basic functionality' do
    it 'should make purl embed request and embed correctly' do
      stub_purl_response_with_fixture(file_purl)
      send_embed_response
      expect(page).to have_css('table')
    end
  end
end
