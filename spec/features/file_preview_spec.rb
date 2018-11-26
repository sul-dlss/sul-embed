# frozen_string_literal: true

require 'rails_helper'

describe 'file preview', js: true do
  include PURLFixtures
  it 'displays a toggle-able section image preview' do
    stub_purl_response_with_fixture(hybrid_object_purl)
    visit_iframe_response
    expect(page).to_not have_css('.sul-embed-preview', visible: true)
    expect(page).to have_css('.sul-embed-preview-toggle', count: 1, text: 'Preview')
    click_link('Preview')
    expect(page).to have_css('.sul-embed-preview', visible: true)
    expect(page).to have_css('.sul-embed-preview-toggle', count: 1, text: 'Close preview')
    expect(page).to have_css('.sul-embed-preview img', count: 1, visible: false)
  end
  it 'displays sul-embed-square-image for file list icon' do
    stub_purl_response_with_fixture(hybrid_object_purl)
    visit_iframe_response('ab123cd4567')
    click_link('Preview')
    expect(page).to have_css('.sul-embed-square-image', visible: false)
    expect(page).to have_css('img[src="https://stacks.stanford.edu/image/iiif/ab123cd4567%2Ftn629pk3948_img_1/square/100,100/0/default.jpg"]', visible: false)
  end
  it 'has (hidden) thumb image' do
    stub_purl_response_with_fixture(hybrid_object_purl)
    visit_iframe_response('ab123cd4567')
    click_link('Preview')
    expect(page).to have_css('.sul-embed-preview')
    expect(page).to have_css('img[src="https://stacks.stanford.edu/image/iiif/ab123cd4567%2Ftn629pk3948_img_1/full/!400,400/0/default.jpg"]', visible: false)
  end
end
