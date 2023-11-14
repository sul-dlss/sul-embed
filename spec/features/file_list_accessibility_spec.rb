# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'file list accessibility', :js do
  include PurlFixtures
  it 'page has relevant sr-only classes' do
    stub_request(:get, 'https://purl.stanford.edu/ignored.xml')
      .to_return(status: 200, body: hybrid_object_purl)
    visit_iframe_response
    expect(page).to have_css 'img.sul-embed-square-image[alt]', visible: :all
    expect(page).to have_content 'Download item 1'
    expect(page).to have_content "Preview\nitem 1"
    expect(page).to have_css 'a[aria-expanded="false"]'
    expect(page).to have_css 'div.sul-embed-preview[aria-hidden="true"]', visible: :all
    click_link 'Preview'
    expect(page).to have_css '.sul-embed-preview img[alt]', visible: :all
    expect(page).to have_content "Close preview\nitem 1"
    expect(page).to have_css 'a[aria-expanded="true"]'
    expect(page).to have_css 'div.sul-embed-preview[aria-hidden="false"]'
  end
end
