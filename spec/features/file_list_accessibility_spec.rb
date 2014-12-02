require 'rails_helper'

describe 'file list accessibility' do
  include PURLFixtures
  it 'should relevant sr-only classes', js: true do
    stub_purl_response_with_fixture(hybrid_object_purl)
    send_embed_response
    expect(page).to have_content 'Download item 1'
    expect(page).to have_content 'Preview item 1'
    expect(page).to have_css 'a[aria-expanded="false"]'
    expect(page).to have_css 'div.sul-embed-preview[aria-hidden="true"]', visible: false
    expect(page).to have_css 'h2.sul-embed-item-count[aria-live="polite"]'
    click_link 'Preview'
    expect(page).to have_content 'Close preview item 1'
    expect(page).to have_css 'a[aria-expanded="true"]'
    expect(page).to have_css 'div.sul-embed-preview[aria-hidden="false"]'
  end
end
