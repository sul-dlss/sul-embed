require 'rails_helper'

describe 'media viewer', js: true do
  include PURLFixtures
  before do
    stub_purl_response_with_fixture(video_purl)
    visit_sandbox
    fill_in_default_sandbox_form('ignored')
    click_button 'Embed'
  end

  it 'renders player in html' do
    expect(page).to have_css('video')
  end

  it 'renders toggle-able panels' do
    find('button.sul-embed-footer-tool.sul-i-infomation-circle').click
    within '.sul-embed-metadata-panel' do
      expect(page).to have_css '.sul-embed-panel-title', text: 'stupid dc title of video'
    end
  end
end
