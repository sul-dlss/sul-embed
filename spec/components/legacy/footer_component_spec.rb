# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Legacy::FooterComponent, type: :component do
  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:object) { Embed::Purl.find('12345') }
  let(:viewer) { Embed::Viewer::Geo.new(request) }
  let(:purl) { build(:purl) }

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
    render_inline(described_class.new(viewer:))
  end

  context 'when there are two files available for download' do
    let(:purl) { build(:purl, contents:) }
    let(:contents) { [build(:resource, :image, files: [build(:resource_file, :world_downloadable), build(:resource_file, :world_downloadable)])] }

    it "returns the object's footer" do
      expect(page).to have_css 'div.sul-embed-footer'
      expect(page).to have_css '[aria-label="open embed this panel"]'
      expect(page).to have_css '[aria-label="2 files available for download"]'
      expect(page).to have_css '.sul-embed-download-count', text: 2
    end
  end

  context 'when the purl includes a version id' do
    let(:request) do
      Embed::Request.new(url: 'http://purl.stanford.edu/bc123df4567/version/1')
    end
    let(:purl) { build(:purl, contents: resources, druid: 'bc123df4567', version_id: '1') }
    let(:resources) { [build(:resource, :file, druid: 'bc123df4567', files: [build(:resource_file, :world_downloadable), build(:resource_file, :world_downloadable)])] }

    it 'returns a versioned stacks url for download all' do
      link = page.find_by_id('sul-embed-footer-download-all')
      expect(link['href']).to eq('https://stacks.stanford.edu/object/bc123df4567/version/1')
    end
  end

  describe 'fullscreen button' do
    context 'when the viewer is configured to use the local fullscreen function' do
      let(:viewer) { Embed::Viewer::DocumentViewer.new(request) }

      it { expect(page).to have_css('button#full-screen-button') }
    end

    context 'when the viewer is not configured to use the local fullscreen function' do
      it { expect(page).to have_no_css('button#full-screen-button') }
    end
  end
end
