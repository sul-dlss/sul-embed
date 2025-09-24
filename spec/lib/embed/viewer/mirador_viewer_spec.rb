# frozen_string_literal: true

require 'rails_helper'
# rubocop:disable RSpec/AnyInstance, RSpec/MessageSpies, RSpec/StubbedMock
RSpec.describe Embed::Viewer::MiradorViewer do
  subject(:mirador_viewer) { described_class.new(request) }

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:purl) { build(:purl) }

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
  end

  describe 'initialize' do
    it 'is an Embed::Viewer::MiradorViewer' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(mirador_viewer).to be_an described_class
    end
  end

  describe '#canvas_index' do
    context 'with an explicit index' do
      let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123', canvas_index: 5) }

      it 'passes through the requested canvas index' do
        expect(mirador_viewer.canvas_index).to eq 5
      end
    end

    context 'with a canvas id' do
      let(:canvas_id) { "#{Settings.purl_url}/abc123/canvas/1" }
      let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123', canvas_id:) }
      let(:manifest_json_response) do
        {
          sequences: [
            {
              canvases: [
                { '@id' => 'random url' },
                { '@id' => canvas_id }
              ]
            }
          ]
        }.to_json
      end

      it 'finds the requested canvas index in the IIIF manifest' do
        allow_any_instance_of(Embed::Purl).to receive(:manifest_json_response).and_return(manifest_json_response)
        expect(mirador_viewer.canvas_index).to eq 1
      end
    end

    context 'with a canvas id that is not found in the manifest' do
      let(:canvas_id) { "#{Settings.purl_url}/abc123/canvas/1" }
      let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123', canvas_id:) }
      let(:manifest_json_response) do
        {
          sequences: [
            {
              canvases: [
                { '@id' => 'random url' },
                { '@id' => 'some other url' }
              ]
            }
          ]
        }.to_json
      end

      it 'finds the requested canvas index in the IIIF manifest' do
        allow_any_instance_of(Embed::Purl).to receive(:manifest_json_response).and_return(manifest_json_response)
        expect(mirador_viewer.canvas_index).to be_nil
      end
    end

    context 'with a canvas index and a canvas id that is not found in the manifest' do
      let(:canvas_id) { "#{Settings.purl_url}/abc123/canvas/1" }
      let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123', canvas_id:, canvas_index: 15) }
      let(:manifest_json_response) do
        {
          sequences: [
            {
              canvases: [
                { '@id' => 'random url' },
                { '@id' => 'some other url' }
              ]
            }
          ]
        }.to_json
      end

      it 'finds the requested canvas index in the IIIF manifest' do
        allow_any_instance_of(Embed::Purl).to receive(:manifest_json_response).and_return(manifest_json_response)
        expect(mirador_viewer.canvas_index).to eq 15
      end
    end
  end

  describe '#canvas_id' do
    before do
      allow_any_instance_of(Embed::Purl).to receive(:manifest_json_response).and_return(manifest_json_response)
      allow_any_instance_of(Embed::Purl).to receive(:druid).and_return('gm059ft3590')
    end

    context 'with an existing canvas id' do
      let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc', canvas_id: 'something') }
      let(:manifest_json_response) do
        {
          sequences: [
            {
              canvases: [
                { '@id' => 'something' },
                { '@id' => 'else' }
              ]
            }
          ]
        }.to_json
      end

      it 'returns the canvas id' do
        expect(mirador_viewer.canvas_id).to eq 'something'
      end
    end

    context 'with non-cocina canvas ids' do
      let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/gm059ft3590', canvas_id: 'https://purl.stanford.edu/gm059ft3590/iiif/canvas/gm059ft3590_1') }
      let(:manifest_json_response) do
        {
          sequences: [
            {
              canvases: [
                { '@id' => 'https://purl.stanford.edu/gm059ft3590/iiif/canvas/cocina-fileSet-gm059ft3590-gm059ft3590_1' },
                { '@id' => 'https://purl.stanford.edu/gm059ft3590/iiif/canvas/cocina-fileSet-gm059ft3590-gm059ft3590_2' }
              ]
            }
          ]
        }.to_json
      end

      it 'rewrites the requested canvas ids to new-style cocina canvas ids' do
        expect(mirador_viewer.canvas_id).to eq 'https://purl.stanford.edu/gm059ft3590/iiif/canvas/cocina-fileSet-gm059ft3590-gm059ft3590_1'
      end
    end

    context 'with a canvas id that does not exist' do
      let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123', canvas_id: 'some/url/does/not/exist') }

      let(:manifest_json_response) do
        {
          sequences: [
            {
              canvases: [
                { '@id' => 'random url' },
                { '@id' => 'some other url' }
              ]
            }
          ]
        }.to_json
      end

      it 'returns nil' do
        expect(mirador_viewer.canvas_id).to be_nil
      end
    end
  end

  describe '#show_attribution_panel?' do
    let(:purl) { instance_double(Embed::Purl, collections: %w[abc 123]) }

    it 'based off of a purls collection being specified in settings' do
      expect(mirador_viewer.show_attribution_panel?).to be true
    end
  end
end
# rubocop:enable RSpec/AnyInstance, RSpec/MessageSpies, RSpec/StubbedMock
