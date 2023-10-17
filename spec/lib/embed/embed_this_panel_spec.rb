# frozen_string_literal: true

require 'rails_helper'
require 'embed/embed_this_panel'

RSpec.describe Embed::EmbedThisPanel, type: 'view' do
  subject do
    Capybara.string(
      described_class.new(viewer:) do
        'Added Panel Content'
      end.to_html
    )
  end

  let(:request) { Embed::Request.new({ url: 'http://purl.stanford.edu/abc123' }, controller) }
  let(:viewer) do
    instance_double(
      Embed::Viewer::CommonViewer,
      height: '555',
      width: '666',
      request:,
      iframe_title: 'File viewer',
      purl_object: instance_double(Embed::Purl, druid: 'oo000oo0000', title: 'The Object Title')
    )
  end

  context 'block param' do
    it 'instantiates without passing a block' do
      expect { described_class.new(viewer:) }.not_to raise_error
    end

    it 'instantiates with a nil block' do
      expect { described_class.new(viewer:) { nil } }.not_to raise_error
    end

    it 'instantiates with an empty string block' do
      expect { described_class.new(viewer:) { '' } }.not_to raise_error
    end
  end

  context 'header' do
    it 'has the panel title' do
      expect(subject).to have_css(
        '.sul-embed-panel-header .sul-embed-panel-title',
        text: 'Embed',
        visible: :all
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
          visible: :all
        )
      end

      it 'has hide_title checkbox' do
        expect(subject).to have_css('input#sul-embed-embed-title[data-embed-attr=hide_title][type=checkbox]', visible: :all)
      end
    end

    it 'includes the content provided in the block' do
      expect(subject).to have_content('Added Panel Content')
    end

    it 'has hide embed checkbox' do
      expect(subject).to have_css('input#sul-embed-embed[data-embed-attr=hide_embed][type=checkbox]', visible: :all)
    end

    it 'has iframe textarea' do
      # more specific tests in feature
      expect(subject).to have_css('textarea#sul-embed-iframe-code', visible: :all)
    end
  end

  describe 'iframe_html' do
    let(:subject) do
      Capybara.string(
        described_class.iframe_html(
          druid: 'oo000oo0000',
          height: '555',
          width: '666',
          request:,
          title: 'Hello world',
          version: '123'
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

    it 'adds the title to html' do
      iframe = subject.find('iframe')
      expect(iframe['title']).to eq 'Hello world'
    end

    describe 'the src' do
      let(:request) do
        Embed::Request.new(
          {
            url: 'https://purl.stanford.edu/abc123',
            maxheight: '555',
            maxwidth: '666',
            hide_title: 'true',
            hide_embed: 'true'
          },
          controller
        )
      end

      it 'includes the relevant request parameters' do
        src = subject.find('iframe')['src']
        expect(src).to match(/&hide_embed=true/)
        expect(src).to match(/&hide_title=true/)
      end

      it 'does not include the maxheight / maxwidth parameters (these are handled in the iframe)' do
        src = subject.find('iframe')['src']
        expect(src).not_to match(/maxheight/)
        expect(src).not_to match(/maxwidth/)
      end

      it 'includes a cache busting parameter' do
        src = subject.find('iframe')['src']
        expect(src).to match(/&_v=123/)
      end
    end
  end
end
