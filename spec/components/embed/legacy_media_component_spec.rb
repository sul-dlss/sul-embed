# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::LegacyMediaComponent, type: :component do
  let(:request) do
    Embed::Request.new(url: 'http://purl.stanford.edu/abc123')
  end
  let(:object) { Embed::Purl.find('12345') }
  let(:viewer) { Embed::Viewer::Media.new(request) }
  let(:purl) { build(:purl, :video) }

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
    render_inline(described_class.new(viewer:))
  end

  it 'renders a video tag' do
    expect(page).to have_css('video', visible: :all)
  end

  context 'with spaces in file names' do
    let(:purl) { build(:purl, :video, contents:) }
    let(:contents) { [build(:resource, :video, files:)] }
    let(:files) { [build(:resource_file, :video, :world_downloadable, filename: 'A video title.mp4')] }

    it 'does not do URL escaping on sources' do
      source = page.find_css('video source', visible: :all).first
      expect(source['src']).not_to include('%20')
      expect(source['src']).not_to include('&amp;')
    end
  end

  context 'with hidden title' do
    let(:request) do
      Embed::Request.new(url: 'http://purl.stanford.edu/abc123', hide_title: 'true')
    end

    it do
      expect(page).not_to have_css '.sul-embed-header', visible: :all
    end
  end
end
