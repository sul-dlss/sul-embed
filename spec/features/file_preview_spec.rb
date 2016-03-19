require 'rails_helper'

describe 'file preview', js: true do
  include PURLFixtures
  it 'displays a toggle-able section image preview' do
    stub_purl_response_with_fixture(hybrid_object_purl)
    send_embed_response
    expect(page).to_not have_css('.sul-embed-preview', visible: true)
    expect(page).to have_css('.sul-embed-preview-toggle', count: 1, text: 'Preview')
    click_link('Preview')
    expect(page).to have_css('.sul-embed-preview', visible: true)
    expect(page).to have_css('.sul-embed-preview-toggle', count: 1, text: 'Close preview')
    expect(page).to have_css('.sul-embed-preview img', count: 1)
  end
end
