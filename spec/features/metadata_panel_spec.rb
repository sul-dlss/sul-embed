require 'rails_helper'

describe 'metadata panel', js: true do
  include PURLFixtures
  it 'should be present after a user clicks the button' do
    stub_purl_response_with_fixture(file_purl)
    send_embed_response
    expect(page).to have_css('.sul-embed-metadata-panel', visible: false)
    page.find('[data-toggle="sul-embed-metadata-panel"]', match: :first).click
    expect(page).to have_css('.sul-embed-metadata-panel', visible: true)
    page.find('[data-toggle="sul-embed-metadata-panel"]', match: :first).click
    expect(page).to have_css('.sul-embed-metadata-panel', visible: false)
  end
  it 'should have use and reproduction and license text' do
    stub_purl_response_with_fixture(file_purl)
    send_embed_response
    page.find('[data-toggle="sul-embed-metadata-panel"]', match: :first).click
    expect(page).to have_css('.sul-embed-metadata-heading', text: 'USE AND REPRODUCTION')
    expect(page).to have_css('.sul-embed-metadata-heading', text: 'LICENSE')
    within '.sul-embed-metadata-panel' do
      expect(page).to have_content 'You can use this.'
    end
  end
end
