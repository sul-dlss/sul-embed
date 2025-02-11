# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Download::AllFilesComponent, type: :component do
  subject(:component) { described_class.new(viewer:) }

  before do
    allow(embed_request).to receive(:purl_object).and_return(purl_object)
    render_inline(component)
  end

  let(:purl_object) { build(:purl, contents:) }
  let(:embed_request) { Embed::Request.new({}) }
  let(:viewer) do
    Embed::Viewer::File.new(embed_request)
  end

  context 'when there are two files available for download' do
    let(:contents) { [build(:resource, :image, files: [build(:resource_file, :world_downloadable), build(:resource_file, :world_downloadable)])] }

    it 'shows the count' do
      expect(page).to have_link 'Download all 2 files', href: 'https://stacks.stanford.edu/object/abc123'
    end
  end

  context 'when the count exceeds the threshold' do
    let(:contents) { [build(:resource, :image, files: files)] }
    let(:files) { Array.new(3001) { build(:resource_file, :world_downloadable) } }

    it 'shows the not available message' do
      expect(page).to have_content 'Bulk download not available. The total file size exceeds the download limit. Please download files individually.'
    end
  end

  context 'when the purl includes a version id' do
    let(:purl_object) { build(:purl, contents:, druid: 'bc123df4567', version_id: '1') }
    let(:contents) { [build(:resource, :file, druid: 'bc123df4567', files: [build(:resource_file, :world_downloadable), build(:resource_file, :world_downloadable)])] }

    it 'returns a versioned stacks url for download all' do
      expect(page).to have_link href: 'https://stacks.stanford.edu/object/bc123df4567/version/1'
    end
  end
end
