# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Download::FileListComponent, type: :component do
  subject(:component) { described_class.new(viewer:) }

  before do
    allow(embed_request).to receive(:purl_object).and_return(purl_object)
    render_inline(component)
  end

  let(:embed_request) { Embed::Request.new({}) }
  let(:viewer) do
    Embed::Viewer::Media.new(embed_request)
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
                    size: 200,
                    contents:,
                    downloadable_files:,
                    all_resource_files: [],
                    downloadable_transcript_files?: false)
  end

  context 'with a media viewer' do
    let(:viewer) do
      Embed::Viewer::Media.new(embed_request)
    end
    let(:media_file) { instance_double(Embed::Purl::ResourceFile, downloadable?: true, title: 'file-abc123.pdf', file_url: '//one', caption?: false, transcript?: false, label_or_filename: 'media filename', location_restricted?: false, stanford_only?: false, size: 100) }
    let(:caption_file) { instance_double(Embed::Purl::ResourceFile, downloadable?: true, title: 'file-abc123.vtt', file_url: '//one', caption?: true, transcript?: false, label_or_filename: 'caption filename', location_restricted?: false, stanford_only?: false, size: 100) }

    context 'when there are no media files' do
      let(:downloadable_files) { [media_file] }
      let(:contents) { [instance_double(Embed::Purl::Resource)] }

      it 'does not have extra headings' do
        expect(page).to have_content 'Download media filename'
        expect(page).to have_no_css('h4', text: 'media filename')
      end
    end

    context 'when there are media files' do
      let(:downloadable_files) { [media_file, caption_file] }
      let(:contents) { [Embed::Purl::Resource.new(description: 'media filename', files: [media_file, caption_file])] }

      it 'does have extra headings' do
        expect(page).to have_link 'Download media filename'
        expect(page).to have_link 'Download caption filename'
        expect(page).to have_css('h4', text: 'media filename')
      end
    end
  end

  context 'with a geo viewer' do
    let(:viewer) do
      Embed::Viewer::Geo.new(embed_request)
    end

    let(:downloadable_files) do
      [
        instance_double(Embed::Purl::ResourceFile, downloadable?: true, filename: 'data.zip', file_url: '//one', caption?: false, transcript?: false, label_or_filename: 'Data', location_restricted?: false, stanford_only?: false, size: 100),
        instance_double(Embed::Purl::ResourceFile, downloadable?: true, filename: 'data_EPSG_4624.zip', file_url: '//one', caption?: true, transcript?: false, label_or_filename: 'Data', location_restricted?: false, stanford_only?: false, size: 100)
      ]
    end
    let(:contents) { [Embed::Purl::Resource.new(description: 'Data', files: downloadable_files)] }

    it 'has download links' do
      expect(page).to have_link 'Download all 2 files'
      expect(page).to have_link 'Download data.zip'
      expect(page).to have_link 'Download data_EPSG_4624.zip'
      expect(page).to have_css('h4', text: 'Data')
    end
  end
end
