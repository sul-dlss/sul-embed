require 'rails_helper'

describe 'image viewer count header', js: true do
  include PURLFixtures
  before do
    stub_purl_response_with_fixture(image_purl)
  end
  describe 'multi image' do
    it 'should show image count in header' do
      visit_iframe_response('fw090jw3474')
      expect(page).to have_css '.sul-embed-item-count', text: '36 images'
    end
  end
  describe 'single image' do
    it 'should show image count in header' do
      visit_iframe_response('sg052hd9120')
      expect(page).to have_css '.sul-embed-item-count', text: '1 image'
    end
  end
end
