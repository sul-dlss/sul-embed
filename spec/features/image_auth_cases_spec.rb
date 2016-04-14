require 'rails_helper'

describe 'image viewer authentication and authorization', js: true do
  include PURLFixtures
  let(:request) { Embed::Request.new(url: 'https://purl.stanford.edu/ab123cd4567') }

  describe 'when public (world)' do
    before do
      stub_purl_response_with_fixture(image_with_pdf_purl)
      visit_sandbox
      fill_in_default_sandbox_form('bb023ts9016')
      click_button 'Embed'
    end
    it 'displays full zoom and download of all pages' do
      expect_zoomable_image
      expect(page).to have_css 'button[data-sul-view-fullscreen="fullscreen"]', visible: true
      page.find('[data-sul-embed-toggle="sul-embed-download-panel"]', match: :first).click
      within '.sul-embed-download-panel' do
        expect_thumb_download
        expect(page).to have_css 'a', text: 'Download (207 x 289)'
        expect(page).to have_css 'a', text: 'Download (414 x 577)'
        expect(page).to have_css 'a', text: 'Download (828 x 1153)'
        expect(page).to have_css 'a', text: 'Download (1655 x 2306)'
        expect(page).to have_css 'a', text: "Download \"Writings - 'How to ...\" (as pdf) 4.76 MB"
      end
    end
  end
  describe '400px and zoom available to world, larger download restricted to SU' do
    before do
      stub_purl_response_with_fixture(image_purl)
      visit_sandbox
      fill_in_default_sandbox_form('bb112zx3193')
      click_button 'Embed'
    end
    pending 'displays zoom and SU restricted downloads' do
      expect_zoomable_image
      page.find('[data-sul-embed-toggle="sul-embed-download-panel"]', match: :first).click
      within '.sul-embed-download-panel' do
        expect_thumb_download
        expect(page).to have_css 'li a', count: 6
        # Because of the Auth roundtrip to get what should be stanford-only,
        # poltergeist doesn't seem to be able to handle it
        expect(page).to have_css 'li.sul-embed-stanford-only a', count: 4
      end
    end
  end
  describe '400px available to world, download and larger available to SU' do
    before do
      stub_purl_response_with_fixture(image_purl)
      visit_sandbox
      fill_in_default_sandbox_form('py305sy7961')
      click_button 'Embed'
    end
    it 'displays login prompt and thumb' do
      expect_thumb_as_image
    end
    it 'download button should be hidden' do
      pending('implement show download button based on authorization')
      raise
    end
  end
end

def expect_authenticate_link
  expect(page).to have_css '.sul-embed-image-x-auth-link', text: 'Stanford-affiliated? Login to view'
end

def expect_thumb_as_image
  expect(page).to have_css '.sul-embed-image-x-restricted-thumb-container'
end

def expect_zoomable_image
  expect(page).to have_css '#sul-embed-image-x .osd-container'
end

def expect_thumb_download
  expect(page).to have_css 'li a', text: 'Download Thumbnail'
end
