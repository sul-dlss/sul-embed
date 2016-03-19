require 'rails_helper'

describe 'image viewer count header', js: true do
  include PURLFixtures
  before do
    stub_purl_response_with_fixture(image_purl)
    visit_sandbox
  end
  describe 'multi image' do
    it 'shows image count in header' do
      fill_in_default_sandbox_form('fw090jw3474')
      click_button 'Embed'
      expect(page).to have_css '.sul-embed-item-count', text: '36 images'
    end
  end
  describe 'single image' do
    it 'shows image count in header' do
      fill_in_default_sandbox_form('sg052hd9120')
      click_button 'Embed'
      expect(page).to have_css '.sul-embed-item-count', text: '1 image'
    end
  end
end
