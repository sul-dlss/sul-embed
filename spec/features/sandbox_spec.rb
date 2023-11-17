# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'embed sandbox page', :js do
  include PurlFixtures

  before do
    stub_purl_xml_response_with_fixture(file_purl_xml)
  end

  it 'returns the iframe output from the embed endpoint' do
    visit page_path(id: 'sandbox')

    expect(page).not_to have_css('iframe')
    fill_in_default_sandbox_form
    click_button 'Embed'
    expect(page).to have_css('iframe')
  end

  it 'passes the customization URL parameters down to the iframe successfully' do
    visit page_path(id: 'sandbox')

    expect(page).not_to have_css('iframe')
    check('hide-title')
    check('hide-search')
    fill_in_default_sandbox_form
    click_button 'Embed'
    iframe_src = page.find('iframe')['src']
    expect(iframe_src).to match(/hide_title=true/)
    expect(iframe_src).to match(/hide_search=true/)
  end

  def fill_in_default_sandbox_form(druid = 'ab123cd4567')
    fill_in 'api-endpoint', with: embed_path
    fill_in 'url-scheme', with: "http://purl.stanford.edu/#{druid}"
  end
end
