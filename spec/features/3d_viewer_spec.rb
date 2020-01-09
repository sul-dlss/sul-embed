# frozen_string_literal: true

require 'rails_helper'

describe '3D Viewer', js: true do
  include PURLFixtures
  let(:purl) { threeD_object_purl }

  before do
    stub_purl_response_with_fixture(purl)
    visit_iframe_response
  end

  it 'renders the 3D viewer for 3D objects' do
    expect(page).to have_css('.sul-embed-3d #virtex-3d-viewer')
  end
end
