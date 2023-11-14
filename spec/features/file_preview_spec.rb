# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'file preview', :js do
  include PurlFixtures
  before do
    stub_request(:get, 'https://purl.stanford.edu/ab123cd4567.xml')
      .to_return(status: 200, body: hybrid_object_purl)
  end

  it 'displays a toggle-able section image preview' do
    visit_iframe_response('ab123cd4567')
    expect(page).not_to have_css('.sul-embed-preview', visible: :visible)
    expect(page).to have_css('.sul-embed-preview-toggle', count: 1, text: 'Preview')
    click_link('Preview')
    expect(page).to have_css('.sul-embed-preview', visible: :visible)
    expect(page).to have_css('.sul-embed-preview-toggle', count: 1, text: 'Close preview')
    expect(page).to have_css('.sul-embed-preview img', count: 1, visible: :all)
  end

  it 'displays sul-embed-square-image for file list icon' do
    visit_iframe_response('ab123cd4567')
    click_link('Preview')
    expect(page).to have_css('.sul-embed-square-image', visible: :all)
    expect(page).to have_css('img[src="https://stacks.stanford.edu/image/iiif/ab123cd4567%2Ftn629pk3948_img_1/square/100,100/0/default.jpg"]', visible: :all)
  end

  it 'has (hidden) thumb image' do
    visit_iframe_response('ab123cd4567')
    click_link('Preview')
    expect(page).to have_css('.sul-embed-preview')
    expect(page).to have_css('img[src="https://stacks.stanford.edu/image/iiif/ab123cd4567%2Ftn629pk3948_img_1/full/!400,400/0/default.jpg"]', visible: :all)
  end
end
