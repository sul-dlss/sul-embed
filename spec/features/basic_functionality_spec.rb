require 'rails_helper'

describe 'basic oembed functionality' do
  include PURLFixtures
  it 'should return a response with required parameters (xml)' do
    stub_purl_response_with_fixture(file_purl)
    visit embed_path(url: 'http://purl.stanford.edu/abc', format: 'xml')
    expect(page).to have_xpath '//oembed'
    expect(page).to have_xpath '//type'
    expect(page).to have_xpath '//version', text: '1.0'
  end
  it 'should return a response with correct parameter fields (xml)' do
    stub_purl_response_with_fixture(file_purl)
    visit embed_path(url: 'http://purl.stanford.edu/abc', format: 'xml')
    expect(page).to have_xpath '//type', text: 'rich'
    expect(page).to have_xpath('//title', text: 'File Title')
    expect(page).to have_xpath('//provider-name', text: 'SUL Embed Service')
    expect(page).to have_xpath '//html'
  end
  it 'should return a response with require parameters (json)' do
    # TODO: leaving this until we figure out the html encoding
  end
end
