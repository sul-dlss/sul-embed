# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::FooterComponent, type: :component do
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

  describe 'fullscreen button' do
    context 'when the viewer is configured to use the local fullscreen function' do
      let(:viewer) { Embed::Viewer::PdfViewer.new(request) }

      it { expect(page).to have_css('button#full-screen-button') }
    end

    context 'when the viewer is not configured to use the local fullscreen function' do
      it { expect(page).to have_no_css('button#full-screen-button') }
    end
  end
end
