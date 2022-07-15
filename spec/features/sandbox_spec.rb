# frozen_string_literal: true

require 'rails_helper'

describe 'embed sandbox page', js: true do
  include PurlFixtures

  before do
    stub_purl_response_with_fixture(file_purl)
  end

  it 'returns the iframe output from the embed endpoint' do
    visit_sandbox
    expect(page).not_to have_css('iframe')
    send_embed_response
    expect(page).to have_css('iframe')
  end

  it 'passes the customization URL parameters down to the iframe successfully' do
    visit_sandbox
    expect(page).not_to have_css('iframe')
    check('hide-title')
    check('hide-search')
    send_embed_response
    iframe_src = page.find('iframe')['src']
    expect(iframe_src).to match(/hide_title=true/)
    expect(iframe_src).to match(/hide_search=true/)
  end
end
