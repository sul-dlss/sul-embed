# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Download::GeoComponent, type: :component do
  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:viewer) { Embed::Viewer::Geo.new(request) }
  let(:response) { geo_purl_public }

  let(:purl) { build(:purl, contents:) }
  let(:contents) { [build(:resource, :file)] }

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
    render_inline(described_class.new(viewer:))
  end

  context 'when hide_download' do
    let(:viewer) do
      Embed::Viewer::Geo.new(
        Embed::Request.new(
          url: 'http://purl.stanford.edu/bc123df4567', hide_download: 'true'
        )
      )
    end

    it 'is empty' do
      expect(page).not_to have_css('body')
    end
  end

  context 'when the file has multiple resources' do
    let(:contents) { [build(:resource, :file, files:), build(:resource, :file, files: [build(:resource_file)])] }
    let(:files) { [build(:resource_file, :video, :world_downloadable, filename: 'data.zip'), build(:resource_file, :video, :world_downloadable, filename: 'data.zip')] }

    it 'generates a file list' do
      expect(page).to have_css 'li', visible: :all, count: 3
      expect(page).to have_link href: 'https://stacks.stanford.edu/file/druid:bc123df4567/data.zip?download=true', visible: :all
    end
  end

  context 'with stanford only' do
    let(:contents) { [build(:resource, :file, files: [build(:resource_file, :stanford_only)])] }

    it 'has the stanford-only class (with screen reader text)' do
      expect(page).to have_css 'li .sul-embed-stanford-only-text .sul-embed-text-hide', text: 'Stanford only', visible: :all
    end
  end

  context 'with location restrictions' do
    let(:contents) { [build(:resource, :file, files: [build(:resource_file, :location_restricted)])] }

    it 'includes text to indicate that they are restricted' do
      expect(page).to have_css 'li .sul-embed-location-restricted-text', text: '(Restricted)', visible: :all
    end
  end
end
