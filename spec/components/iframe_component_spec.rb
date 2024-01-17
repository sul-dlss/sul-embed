# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IframeComponent, type: :component do
  subject(:iframe) { page.find_css('iframe').first }

  before do
    render_inline(described_class.new(viewer:, version: '123')) { 'Added Panel Content' }
  end

  let(:embed_request) { Embed::Request.new({ url: 'http://purl.stanford.edu/abc123' }) }

  let(:viewer) do
    instance_double(
      Embed::Viewer::CommonViewer,
      height: '555',
      width: '666',
      embed_request:,
      iframe_title: 'Hello world',
      purl_object: instance_double(Embed::Purl, druid: 'oo000oo0000', title: 'The Object Title')
    )
  end

  describe 'the height' do
    subject { iframe['height'] }

    it { is_expected.to eq '555px' }

    context 'when the fullheight flag is set' do
      let(:embed_request) do
        Embed::Request.new({ url: 'http://purl.stanford.edu/abc123', fullheight: 'true' })
      end

      it { is_expected.to eq '100%' }
    end
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

    it 'includes a cache busting parameter' do
      expect(src).to match(/&_v=123/)
    end
  end
end
