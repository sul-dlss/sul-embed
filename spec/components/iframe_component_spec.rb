# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IframeComponent, type: :component do
  subject(:iframe) { page.find_css('iframe').first }

  before do
    render_inline(described_class.new(viewer:, version: '123')) { 'Added Panel Content' }
  end

  let(:embed_request) { Embed::Request.new({ url: 'http://purl.stanford.edu/abc123' }) }
  let(:purl_object) { instance_double(Embed::Purl, druid: 'oo000oo0000', title: 'The Object Title', version_id: nil) }
  let(:viewer) do
    instance_double(
      Embed::Viewer::CommonViewer,
      height: '555px',
      width: '666px',
      embed_request:,
      iframe_title: 'Hello world',
      purl_object:
    )
  end

  describe 'the width' do
    subject { iframe['width'] }

    it { is_expected.to eq '666px' }
  end

  describe 'the height' do
    subject { iframe['height'] }

    it { is_expected.to eq '555px' }
  end

  it 'adds the title to html' do
    expect(iframe['title']).to eq 'Hello world'
  end

  describe 'the src' do
    subject(:src) { iframe['src'] }

    let(:embed_request) do
      Embed::Request.new(
        url: 'https://purl.stanford.edu/abc123',
        maxheight: '555',
        maxwidth: '666',
        hide_title: 'true',
        hide_embed: 'true'
      )
    end

    it 'includes the relevant request parameters' do
      expect(src).to match(/&hide_embed=true/)
      expect(src).to match(/&hide_title=true/)
    end

    it 'does not include the maxheight / maxwidth parameters (these are handled in the iframe)' do
      expect(src).not_to match(/maxheight/)
      expect(src).not_to match(/maxwidth/)
    end

    it 'links to the versionless purl url' do
      expect(src).to match(%r{iframe\?url=https://purl\.stanford\.edu/oo000oo0000&})
    end

    it 'includes a cache busting parameter' do
      expect(src).to match(/&_v=123/)
    end

    context 'when purl object has a version id' do
      let(:purl_object) { instance_double(Embed::Purl, druid: 'oo000oo0000', title: 'The Object Title', version_id: '3') }

      it 'includes the relevant request parameters' do
        expect(src).to match(/&hide_embed=true/)
        expect(src).to match(/&hide_title=true/)
      end

      it 'does not include the maxheight / maxwidth parameters (these are handled in the iframe)' do
        expect(src).not_to match(/maxheight/)
        expect(src).not_to match(/maxwidth/)
      end

      it 'links to the versionful purl url' do
        expect(src).to match(%r{iframe\?url=https://purl\.stanford\.edu/oo000oo0000/version/3&})
      end

      it 'includes a cache busting parameter' do
        expect(src).to match(/&_v=123/)
      end
    end
  end
end
