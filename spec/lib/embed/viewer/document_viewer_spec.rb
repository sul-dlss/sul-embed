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
end
