require 'rails_helper'

describe 'file viewer search bar', js: true do
  include PURLFixtures
  it 'limits shown files when text is entered' do
    stub_purl_response_with_fixture(file_purl)
    visit_sandbox
    fill_in_default_sandbox_form
    fill_in('min-files', with: '1')
    click_button 'Embed'
    expect(page).to have_css('.sul-embed-count', count: 1)
    expect(page).to have_css '.sul-embed-item-count', text: '1 item'
    fill_in 'sul-embed-search-input', with: 'test'
    expect(page).not_to have_css('.sul-embed-count')
    expect(page).to have_css '.sul-embed-item-count', text: '0 items'
  end
  it 'does not display the search box when the number of files are beneath the threshold' do
    stub_purl_response_with_fixture(file_purl)
    send_embed_response
    expect(page).not_to have_css('.sul-embed-search-input')
  end
  it 'hides the search box when requested' do
    stub_purl_response_with_fixture(file_purl)
    visit_sandbox
    check('Hide search?')
    click_button 'Embed'
    expect(page).not_to have_css('.sul-embed-search')
  end
end
