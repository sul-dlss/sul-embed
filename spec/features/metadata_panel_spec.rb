require 'rails_helper'

describe 'metadata panel', js: true do
  include PURLFixtures
  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  it 'should be present after a user clicks the button' do
    stub_purl_response_with_fixture(file_purl)
    visit_iframe_response
    expect(page).to have_css('.sul-embed-metadata-panel', visible: false)
    page.find('[data-sul-embed-toggle="sul-embed-metadata-panel"]', match: :first).click
    expect(page).to have_css('.sul-embed-metadata-panel', visible: true)
    page.find('[data-sul-embed-toggle="sul-embed-metadata-panel"]', match: :first).click
    expect(page).to have_css('.sul-embed-metadata-panel', visible: false)
  end
  it 'should have purl link, use and reproduction, and license text' do
    stub_purl_response_with_fixture(file_purl)
    visit_iframe_response
    page.find('[data-sul-embed-toggle="sul-embed-metadata-panel"]', match: :first).click
    expect(page).to have_css('dt', text: 'CITATION URL')
    expect(page).to have_css('dt', text: 'USE AND REPRODUCTION')
    expect(page).to have_css('dt', text: 'LICENSE')
    within '.sul-embed-metadata-panel' do
      expect(page).to have_css 'dd', text: 'You can use this.'
    end
  end
end
