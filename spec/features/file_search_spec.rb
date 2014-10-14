require 'rails_helper'

describe 'file viewer search bar', js: true do
  include PURLFixtures
  it 'should limit shown files when text is entered' do
    stub_purl_response_with_fixture(file_purl)
    send_embed_response
    expect(page).to have_css('.sul-embed-count', count: 1)
    fill_in 'sul-embed-search-input', with: 'test'
    expect(page).to_not have_css('.sul-embed-count')
  end
end
