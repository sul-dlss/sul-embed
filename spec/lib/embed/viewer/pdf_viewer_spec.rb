# frozen_string_literal: true

require 'rails_helper'

describe Embed::Viewer::PdfViewer do
  subject(:pdf_viewer) { described_class.new(request) }

  let(:purl) do
    double(
      Embed::Purl,
      contents: [
        double(type: 'file', files: [double(title: 'file-abc123.pdf'), double(title: 'file-xyz321.pdf')]),
        double(type: 'document', files: [double(title: 'doc-abc123.pdf'), double(title: 'doc-xyz321.pdf')])
      ],
      druid: 'abc123'
    )
  end
  let(:request) { double(Embed::Request, purl_object: purl) }

  describe '#pdf_files' do
    it 'returns the full file URL for the PDFs in an object' do
      expect(pdf_viewer.pdf_files.length).to eq 2
      expect(pdf_viewer.pdf_files.first).to match(%r{/file/druid:abc123/doc-abc123\.pdf$})
      expect(pdf_viewer.pdf_files.last).to match(%r{/file/druid:abc123/doc-xyz321\.pdf})
    end
  end

  describe '#all_documents_location_restricted?' do
    context 'when all the files in the documents are location restricted' do
      let(:purl) do
        double(
          Embed::Purl,
          contents: [
            double(type: 'document', files: [double(title: 'doc-abc123.pdf', location_restricted?: true)])
          ],
          druid: 'abc123'
        )
      end
      it { expect(pdf_viewer.all_documents_location_restricted?).to be true }
    end

    context 'when all the files in the documents are not location restricted' do
      let(:purl) do
        double(
          Embed::Purl,
          contents: [
            double(type: 'document', files: [double(title: 'doc-abc123.pdf', location_restricted?: false)])
          ],
          druid: 'abc123'
        )
      end
      it { expect(pdf_viewer.all_documents_location_restricted?).to be false }
    end
  end
end
