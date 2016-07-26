require 'rails_helper'

describe 'embed sandbox page', js: true do
  include PURLFixtures
  it 'returns the iframe output from the embed endpoint' do
    stub_purl_response_with_fixture(file_purl)

    visit_sandbox
    expect(page).not_to have_css('iframe')
    send_embed_response
    expect(page).to have_css("iframe[src^='#{Settings.embed_iframe_url}']")
  end
end
