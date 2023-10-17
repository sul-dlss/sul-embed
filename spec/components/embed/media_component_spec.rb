# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::MediaComponent, type: :component do
  include PurlFixtures

  let(:request) do
    Embed::Request.new(
      { url: 'http://purl.stanford.edu/abc123' },
      vc_test_controller
    )
  end
  let(:object) { Embed::Purl.new('12345') }
  let(:viewer) { Embed::Viewer::Media.new(request) }
  let(:response) { video_purl }

  before do
    allow(request).to receive(:purl_object).and_return(object)
    allow(viewer).to receive(:asset_host).and_return('http://example.com/')
    allow(object).to receive(:response).and_return(response)
    render_inline(described_class.new(viewer:))
  end

  it 'implements the MediaTag class appropriately and gets a video tag' do
    expect(page).to have_css('video', visible: :all)
  end

  describe 'media tag' do
    let(:response) { video_with_spaces_in_filename_purl }

    it 'does not do URL escaping on sources' do
      source = page.find_css('video source', visible: :all).first
      expect(source['src']).not_to include('%20')
      expect(source['src']).not_to include('&amp;')
    end
  end

  context 'with hidden title' do
    let(:request) do
      Embed::Request.new(
        { url: 'http://purl.stanford.edu/abc123', hide_title: 'true' },
        vc_test_controller
      )
    end

    it do
      expect(page).not_to have_css '.sul-embed-header', visible: :all
    end
  end
end
