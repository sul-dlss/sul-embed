# frozen_string_literal: true

require 'rails_helper'

describe Embed::Viewer::Virtex3dViewer do
  subject(:viewer) { described_class.new(request) }

  let(:purl) do
    double(
      Embed::Purl,
      contents: [
        double(three_dimensional?: true, files: [double(title: 'obj1.obj')])
      ],
      druid: 'abc123'
    )
  end
  let(:request) { double(Embed::Request, purl_object: purl) }

  describe '#three_dimensional_files' do
    it 'returns the full file URL for the PDFs in an object' do
      expect(viewer.three_dimensional_files.length).to eq 1
      expect(viewer.three_dimensional_files.first).to match(%r{/file/druid:abc123/obj1\.obj$})
    end
  end
end
