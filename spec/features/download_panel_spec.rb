require 'rails_helper'

describe 'download panel', js: true do
  include PURLFixtures
  let(:request) { Embed::Request.new( {url: 'http://purl.stanford.edu/ab123cd4567'}) }
  before do
    stub_purl_response_with_fixture(image_purl)
    send_embed_response
  end

  it 'should be present after a user clicks the button' do
    expect(page).to have_css('.sul-embed-download-panel', visible: false)
    page.find('button[data-toggle="sul-embed-download-panel"]', visible: true)

    skip 'verify image viewer plugin is correctly initialized'
    page.find('[data-toggle="sul-embed-download-panel"]', match: :first).click
    expect(page).to have_css('.sul-embed-download-panel', visible: true)
  end

end
