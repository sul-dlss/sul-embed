# frozen_string_literal: true

require 'rails_helper'
require 'embed/embed_this_panel'
describe Embed::EmbedThisPanel do
  let(:request) { Embed::Request.new(url: 'https://purl.stanford.edu/abc123') }
  subject do
    Capybara.string(
      described_class.new(
        druid: 'oo000oo0000',
        height: '555',
        width: '666',
        request: request,
        purl_object_title: 'The Object Title'
      ) do
        'Added Panel Content'
      end.to_html
    )
  end

  context 'block param' do
    it 'instantiates without passing a block' do
      expect { described_class.new(druid: 'oo000oo0000', height: '1', width: '2', request: request, purl_object_title: 'a') }.not_to raise_error
    end
    it 'instantiates with an empty block' do
      expect { described_class.new(druid: 'oo000oo0000', height: '1', width: '2', request: request, purl_object_title: 'a') {} }.not_to raise_error
    end
    it 'instantiates with a nil block' do
      expect { described_class.new(druid: 'oo000oo0000', height: '1', width: '2', request: request, purl_object_title: 'a') { nil } }.not_to raise_error
    end
    it 'instantiates with an empty string block' do
      expect { described_class.new(druid: 'oo000oo0000', height: '1', width: '2', request: request, purl_object_title: 'a') { '' } }.not_to raise_error
    end
  end

  context 'header' do
    it 'has the panel title' do
      expect(subject).to have_css(
        '.sul-embed-panel-header .sul-embed-panel-title',
        text: 'Embed',
        visible: false
      )
    end
  end

  context 'body' do
    context 'title' do
      it 'has the purl object title' do
        expect(subject).to have_content(/title\s*\(The Object Title\)/)
      end
      it 'has span with only the purl object title' do
        expect(subject).to have_css(
          'span',
          text: '(The Object Title)',
          visible: false
        )
      end
      it 'has hide_title checkbox' do
        expect(subject).to have_css('input#sul-embed-embed-title[data-embed-attr=hide_title][type=checkbox]', visible: false)
      end
    end
    it 'includes the content provided in the block' do
      expect(subject).to have_content('Added Panel Content')
    end
    it 'has hide embed checkbox' do
      expect(subject).to have_css('input#sul-embed-embed[data-embed-attr=hide_embed][type=checkbox]', visible: false)
    end
    it 'has iframe textarea' do
      # more specific tests in feature
      expect(subject).to have_css('textarea#sul-embed-iframe-code', visible: false)
    end
  end

  describe 'iframe_html' do
    let(:subject) do
      Capybara.string(
        described_class.iframe_html(
          druid: 'oo000oo0000',
          height: '555',
          width: '666',
          request: request
        )
      )
    end

    describe 'the height' do
      it 'is the set height in px' do
        iframe = subject.find('iframe')
        expect(iframe['height']).to eq '555px'
      end

      context 'when the fullheight flag is set' do
        before { expect(request).to receive(:fullheight?).and_return(true) }
        it 'is 100%' do
          iframe = subject.find('iframe')
          expect(iframe['height']).to eq '100%'
        end
      end
    end

    describe 'the src' do
      let(:request) do
        Embed::Request.new(
          url: 'https://purl.stanford.edu/abc123',
          maxheight: '555',
          maxwidth: '666',
          hide_title: 'true',
          hide_embed: 'true'
        )
      end

      it 'includes the relevant request parameters' do
        src = subject.find('iframe')['src']
        expect(src).to match(/&maxheight=555/)
        expect(src).to match(/&maxwidth=666/)
        expect(src).to match(/&hide_embed=true/)
        expect(src).to match(/&hide_title=true/)
      end
    end
  end
end
