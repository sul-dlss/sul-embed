# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Viewer::DocumentViewer do
  subject(:pdf_viewer) { described_class.new(request) }

  let(:purl) do
    instance_double(
      Embed::Purl,
      contents: [
        instance_double(Embed::Purl::Resource, type: 'file',
                                               files: [
                                                 instance_double(Embed::Purl::ResourceFile, title: 'file-abc123.pdf', file_url: '//one'),
                                                 instance_double(Embed::Purl::ResourceFile, title: 'file-xyz321.pdf', file_url: '//two')
                                               ]),
        instance_double(Embed::Purl::Resource, type: 'document',
                                               files: [
                                                 instance_double(Embed::Purl::ResourceFile, title: 'doc-abc123.pdf', file_url: '//file/druid:abc123/doc-abc123.pdf'),
                                                 instance_double(Embed::Purl::ResourceFile, title: 'doc-xyz321.pdf', file_url: '//file/druid:abc123/doc-xyz321.pdf')
                                               ])
      ],
      druid: 'abc123'
    )
  end
  let(:request) { instance_double(Embed::Request, purl_object: purl) }

  describe '#pdf_files' do
    it 'returns the full file URL for the PDFs in an object' do
      expect(pdf_viewer.pdf_files.length).to eq 2
      expect(pdf_viewer.pdf_files.first).to match(%r{/file/druid:abc123/doc-abc123\.pdf$})
      expect(pdf_viewer.pdf_files.last).to match(%r{/file/druid:abc123/doc-xyz321\.pdf})
    end
  end

  describe '#available?' do
    context 'when the first file in the documents is location restricted and downloadable' do
      let(:purl) do
        instance_double(
          Embed::Purl,
          contents: [
            instance_double(Embed::Purl::Resource, type: 'document', files: [instance_double(Embed::Purl::ResourceFile, title: 'doc-abc123.pdf', location_restricted?: true, no_download?: false)])
          ],
          druid: 'abc123'
        )
      end

      it { expect(pdf_viewer.available?).to be true }
    end

    context 'when the first file in the document is not location restricted and downloadable' do
      let(:purl) do
        instance_double(
          Embed::Purl,
          contents: [
            instance_double(Embed::Purl::Resource, type: 'document', files: [instance_double(Embed::Purl::ResourceFile, title: 'doc-abc123.pdf', location_restricted?: false, no_download?: false)])
          ],
          druid: 'abc123'
        )
      end

      it { expect(pdf_viewer.available?).to be true }
    end

    context 'when the first file in the document is not downloadable' do
      let(:purl) do
        instance_double(
          Embed::Purl,
          contents: [
            instance_double(Embed::Purl::Resource, type: 'document', files: [instance_double(Embed::Purl::ResourceFile, title: 'doc-abc123.pdf', location_restricted?: false, no_download?: true)])
          ],
          druid: 'abc123'
        )
      end

      it { expect(pdf_viewer.available?).to be false }
    end
  end
end
