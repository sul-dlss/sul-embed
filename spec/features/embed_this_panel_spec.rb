require 'rails_helper'

describe 'embed this panel', js: true do
  include PURLFixtures
  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  before do
    stub_purl_response_with_fixture(spec_fixture)
    send_embed_response
  end
  describe 'embed code' do
    let(:spec_fixture) { file_purl }
    it 'includes the allowfullscreen no-scrolling, no-border, and no margin/padding attributes' do
      page.find('[data-sul-embed-toggle="sul-embed-embed-this-panel"]', match: :first).trigger('click')
      expect(page.find('.sul-embed-embed-this-panel textarea').value).to match(/<iframe.*frameborder='0'.*><\/iframe>/)
      expect(page.find('.sul-embed-embed-this-panel textarea').value).to match(/<iframe.*marginwidth='0'.*><\/iframe>/)
      expect(page.find('.sul-embed-embed-this-panel textarea').value).to match(/<iframe.*marginheight='0'.*><\/iframe>/)
      expect(page.find('.sul-embed-embed-this-panel textarea').value).to match(/<iframe.*scrolling='no'.*><\/iframe>/)
      expect(page.find('.sul-embed-embed-this-panel textarea').value).to match(/<iframe.*allowfullscreen.*><\/iframe>/)
    end
    it 'includes height and width attributes' do
      page.find('[data-sul-embed-toggle="sul-embed-embed-this-panel"]', match: :first).trigger('click')
      expect(page.find('.sul-embed-embed-this-panel textarea').value).to match(/<iframe.*height='400px'.*><\/iframe>/)
      expect(page.find('.sul-embed-embed-this-panel textarea').value).to match(/<iframe.*width='400px'.*><\/iframe>/)
    end
  end
  describe 'file objects' do
    let(:spec_fixture) { file_purl }
    it 'are present after a user clicks the button' do
      expect(page).to have_css('.sul-embed-embed-this-panel', visible: false)
      page.find('[data-sul-embed-toggle="sul-embed-embed-this-panel"]', match: :first).trigger('click')
      expect(page).to have_css('.sul-embed-embed-this-panel', visible: true)
      page.find('[data-sul-embed-toggle="sul-embed-embed-this-panel"]', match: :first).trigger('click')
      expect(page).to have_css('.sul-embed-embed-this-panel', visible: false)
    end
    it 'have the form elements for updating the embed code' do
      page.find('[data-sul-embed-toggle="sul-embed-embed-this-panel"]', match: :first).trigger('click')
      expect(page).to have_css('.sul-embed-options-label', text: 'SELECT OPTIONS:')
      expect(page).to have_css('input#sul-embed-embed-title[type="checkbox"]')
      expect(page).to have_css('input#sul-embed-embed-search[type="checkbox"]')
      expect(page).to have_css('input#sul-embed-embed[type="checkbox"]')
      expect(page).to have_css('textarea#sul-embed-iframe-code')
    end
    it 'update the textarea when the checkboxes are selected' do
      page.find('[data-sul-embed-toggle="sul-embed-embed-this-panel"]', match: :first).trigger('click')
      expect(page.find('.sul-embed-embed-this-panel textarea').value).to match(/src='\S+\/iframe\?url=https:\/\/purl\.stanford\.edu\/ab123cd4567'/)
      page.find("input#sul-embed-embed-search[type='checkbox']").trigger('click')
      expect(page.find('.sul-embed-embed-this-panel textarea').value).to match(/src='\S+\/iframe\?url=https:\/\/purl\.stanford\.edu\/ab123cd4567&hide_search=true'/)
      page.find("input#sul-embed-embed-search[type='checkbox']").trigger('click')
      expect(page.find('.sul-embed-embed-this-panel textarea').value).to match(/src='\S+\/iframe\?url=https:\/\/purl\.stanford\.edu\/ab123cd4567'/)
    end
  end
  describe 'image objects' do
    let(:spec_fixture) { image_purl }
    it 'include the form elements for downloading an image' do
      page.find('[data-sul-embed-toggle="sul-embed-embed-this-panel"]', match: :first).trigger('click')
      expect(page).to have_css('input#sul-embed-embed-download[type="checkbox"]')
    end
  end
end
