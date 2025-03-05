# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PdfComponent, type: :component do
  include PurlFixtures

  let(:url) { 'https://purl.stanford.edu/sq929fn8035' }
  let(:embed_request) { Embed::Request.new(url:) }
  let(:viewer) { Embed::ViewerFactory.new(embed_request).viewer }
  let(:user_agent_string) { '' }

  before do
    vc_test_request.headers['User-Agent'] = user_agent_string
    stub_request(:get, 'https://purl.stanford.edu/sq929fn8035.json')
      .to_return(status: 200, body: pdf_public_json, headers: {})
    render_inline(described_class.new(viewer:))
  end

  it 'draws the page' do
    # The component has a hidden attribute which is removed by the javascript, so search with `visibile: :all'
    expect(page).to have_css('button[aria-label="Full screen"]', visible: :all)
    within 'header' do
      expect(page).to have_content 'Fantasia Apocalyptica musical score (manuscript) : Four trumpets. Chapter 8'
    end
  end

  it 'includes access restriction method section' do
    expect(page).to have_css('div[data-file-auth-target="locationRestriction"]', visible: :all)
  end

  context 'when hide_title is passed' do
    let(:embed_request) { Embed::Request.new(url:, hide_title: 'true') }

    it 'displays the page' do
      within 'header' do
        expect(page).to have_no_content 'Fantasia Apocalyptica musical score (manuscript) : Four trumpets. Chapter 8'
      end
    end
  end

  context 'when the browser is chrome' do
    let(:user_agent_string) { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36' }

    it 'does not render the full screen button' do
      expect(page).to have_no_css('button[aria-label="Full screen"]')
    end
  end

  context 'when the browser is Edge' do
    let(:user_agent_string) { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 Edg/126.0.0.0' }

    it 'does not render the full screen button' do
      expect(page).to have_no_css('button[aria-label="Full screen"]')
    end
  end
end
