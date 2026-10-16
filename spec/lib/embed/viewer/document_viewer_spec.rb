# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Viewer::DocumentViewer do
  subject(:viewer) { described_class.new(request) }

  let(:request) { Embed::Request.new({ url: 'http://purl.stanford.edu/abc123', canvas_index: }.compact) }
  let(:canvas_index) { '3' }
  let(:purl) { build(:purl, :document) }

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
  end

  describe '#page' do
    it 'converts the zero-based canvas index to a one-based PDF page' do
      expect(viewer.page).to eq 4
    end

    context 'without a canvas index' do
      let(:canvas_index) { nil }

      it 'does not select a PDF page' do
        expect(viewer.page).to be_nil
      end
    end

    context 'with an invalid canvas index' do
      let(:canvas_index) { 'invalid' }

      it 'does not select a PDF page' do
        expect(viewer.page).to be_nil
      end
    end

    context 'with an explicit page' do
      let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123', page: '7') }

      it 'uses it as a one-based page' do
        expect(viewer.page).to eq 7
      end
    end

    context 'with both a page and a canvas index' do
      let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123', page: '7', canvas_index: '3') }

      it 'prefers the explicit page' do
        expect(viewer.page).to eq 7
      end
    end

    context 'with a page that is not a positive number' do
      let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123', page: '0') }

      it 'does not select a PDF page' do
        expect(viewer.page).to be_nil
      end
    end
  end

  describe 'file selection' do
    let(:request) { Embed::Request.new({ url: 'http://purl.stanford.edu/abc123', filename: }.compact) }
    let(:filename) { nil }
    let(:purl) do
      build(:purl, :document, contents: [
              build(:resource, :file), # not a PDF, so the viewer cannot display it
              build(:resource, :document, files: [build(:resource_file, :document, filename: 'issue-1.pdf')]),
              build(:resource, :document, files: [build(:resource_file, :document, filename: 'issue-2.pdf')])
            ])
    end

    describe '#pdf_files' do
      it 'omits files that are not PDFs' do
        expect(viewer.pdf_files.map(&:filename)).to eq %w[issue-1.pdf issue-2.pdf]
      end
    end

    describe '#selected_file' do
      it 'opens on the first PDF when no filename was requested' do
        expect(viewer.selected_file.filename).to eq 'issue-1.pdf'
      end

      context 'when a filename was requested' do
        let(:filename) { 'issue-2.pdf' }

        it 'opens on that PDF' do
          expect(viewer.selected_file.filename).to eq 'issue-2.pdf'
        end
      end

      context 'when the requested filename is not on the object' do
        let(:filename) { 'nope.pdf' }

        it 'falls back to the first PDF' do
          expect(viewer.selected_file.filename).to eq 'issue-1.pdf'
        end
      end

      context 'when the requested filename is not a PDF' do
        let(:filename) { 'data.zip' }

        it 'falls back to the first PDF' do
          expect(viewer.selected_file.filename).to eq 'issue-1.pdf'
        end
      end
    end

    describe '#selected_file_url' do
      let(:filename) { 'issue-2.pdf' }

      it 'identifies the selected PDF the way the IIIF manifest does' do
        expect(viewer.selected_file_url).to eq 'https://stacks.stanford.edu/file/bc123df4567/issue-2.pdf'
      end
    end
  end
end
