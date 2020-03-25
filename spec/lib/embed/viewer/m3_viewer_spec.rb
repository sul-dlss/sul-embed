# frozen_string_literal: true

require 'rails_helper'

describe Embed::Viewer::M3Viewer do
  include PURLFixtures
  subject(:m3_viewer) { Embed::Viewer::M3Viewer.new(request) }

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:purl) { "#{Settings.purl_url}/abc123" }

  describe 'initialize' do
    it 'should be an Embed::Viewer::M3Viewer' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(m3_viewer).to be_an Embed::Viewer::M3Viewer
    end
  end

  describe '#canvas_index' do
    context 'with an explicit index' do
      let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123', canvas_index: 5) }

      it 'passes through the requested canvas index' do
        expect(m3_viewer.canvas_index).to eq 5
      end
    end

    context 'with a canvas id' do
      let(:canvas_id) { "#{Settings.purl_url}/abc123/canvas/1" }
      let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123', canvas_id: canvas_id) }
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
        allow_any_instance_of(Embed::PURL).to receive(:manifest_json_response).and_return(manifest_json_response)
        expect(m3_viewer.canvas_index).to eq 1
      end
    end

    context 'with a canvas id that is not found in the manifest' do
      let(:canvas_id) { "#{Settings.purl_url}/abc123/canvas/1" }
      let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123', canvas_id: canvas_id) }
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
        allow_any_instance_of(Embed::PURL).to receive(:manifest_json_response).and_return(manifest_json_response)
        expect(m3_viewer.canvas_index).to eq nil
      end
    end

    context 'with a canvas index and a canvas id that is not found in the manifest' do
      let(:canvas_id) { "#{Settings.purl_url}/abc123/canvas/1" }
      let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123', canvas_id: canvas_id, canvas_index: 15) }
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
        allow_any_instance_of(Embed::PURL).to receive(:manifest_json_response).and_return(manifest_json_response)
        expect(m3_viewer.canvas_index).to eq 15
      end
    end
  end

  describe '#show_attribution_panel?' do
    let(:purl) { instance_double('Purl', collections: %w[abc 123]) }
    it 'based off of a purls collection being specified in settings' do
      expect(request).to receive(:purl_object).and_return(purl)
      expect(m3_viewer.show_attribution_panel?).to eq true
    end
  end
end
