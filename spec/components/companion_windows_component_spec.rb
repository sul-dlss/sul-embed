# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompanionWindowsComponent, type: :component do
  subject(:companion_windows_component) { described_class.new(viewer:) }

  before do
    allow(embed_request).to receive(:purl_object).and_return(purl_object)
    render_inline(companion_windows_component)
  end

  let(:embed_request) { Embed::Request.new({}) }

  describe 'Media viewer' do
    let(:viewer) do
      Embed::Viewer::Media.new(embed_request)
    end

    let(:purl_object) do
      instance_double(Embed::Purl,
                      title: 'foo',
                      purl_url: 'https://purl.stanford.edu/123',
                      manifest_json_url: 'https://purl.stanford.edu/123/iiif3/manifest',
                      use_and_reproduction: '',
                      copyright: '',
                      license: '',
                      druid: '123',
                      version_id: nil,
                      contents: [],
                      downloadable_files: [],
                      downloadable_transcript_files?: false)
    end

    it 'displays the page' do
      expect(page).to have_content 'About this item'
      expect(page).to have_content 'Contents'
      expect(page).to have_content 'Rights'
    end
  end

  describe 'Document viewer' do
    let(:viewer) do
      Embed::Viewer::DocumentViewer.new(embed_request)
    end

    let(:purl_object) do
      instance_double(Embed::Purl,
                      title: 'foo',
                      purl_url: 'https://purl.stanford.edu/123',
                      manifest_json_url: 'https://purl.stanford.edu/123/iiif3/manifest',
                      use_and_reproduction: '',
                      copyright: '',
                      license: '',
                      druid: '123',
                      version_id: nil,
                      contents:,
                      downloadable_files: [],
                      resource_files: files,
                      downloadable_transcript_files?: false)
    end

    let(:resource_file) { instance_double(Embed::Purl::Resource) }
    let(:file) { instance_double(Embed::Purl::ResourceFile, file_url: '/url') }
    let(:files) { [file, file] }

    context 'when purl object has no contents' do
      let(:contents) { [] }

      it 'displays the page without contents' do
        expect(page).to have_content 'About this item'
        expect(page).to have_no_content 'Contents'
        expect(page).to have_content 'Rights'
      end
    end

    context 'when purl object has 2 files and 1 resource' do
      let(:contents) { [resource_file] }

      it 'displays the page without contents' do
        expect(page).to have_content 'About this item'
        expect(page).to have_no_content 'Contents'
        expect(page).to have_content 'Rights'
      end
    end

    context 'when purl object has 2 resources' do
      let(:contents) { [resource_file, resource_file] }

      it 'displays the page without contents' do
        expect(page).to have_content 'About this item'
        expect(page).to have_content 'Contents'
        expect(page).to have_content 'Rights'
      end
    end
  end
end
