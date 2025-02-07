# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Download::AllFilesComponent, type: :component do
  subject(:component) { described_class.new(viewer:) }

  before do
    allow(embed_request).to receive(:purl_object).and_return(purl_object)
    render_inline(component)
  end

  let(:embed_request) { Embed::Request.new({}) }
  let(:viewer) do
    Embed::Viewer::File.new(embed_request)
  end

  let(:downloadable_files) { [] }
  let(:purl_object) do
    instance_double(Embed::Purl,
                    title: 'foo',
                    purl_url: 'https://purl.stanford.edu/123',
                    manifest_json_url: 'https://purl.stanford.edu/123/iiif/manifest',
                    use_and_reproduction: '',
                    copyright: '',
                    license: '',
                    druid: '123',
                    version_id: nil,
                    contents: [],
                    downloadable_files:,
                    downloadable_transcript_files?: false)
  end

  context 'when there are two files available for download' do
    let(:purl_object) { build(:purl, contents:) }
    let(:contents) { [build(:resource, :image, files: [build(:resource_file, :world_downloadable), build(:resource_file, :world_downloadable)])] }

    it 'shows the count' do
      expect(page).to have_link 'Download all 2 files', href: 'https://stacks.stanford.edu/object/abc123'
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
