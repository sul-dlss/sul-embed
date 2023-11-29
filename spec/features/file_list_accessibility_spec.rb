# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'file list accessibility', :js do
  include PurlFixtures
  it 'page has relevant sr-only classes' do
    stub_purl_xml_response_with_fixture(hybrid_object_purl)
    visit_iframe_response
    expect(page).to have_css 'img.sul-embed-square-image[alt]', visible: :all
    expect(page).to have_content 'Download item 1'
  end
end
