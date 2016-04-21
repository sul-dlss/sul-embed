require 'rails_helper'
require 'embed/embed_this_panel'
describe Embed::EmbedThisPanel do
  subject do
    Capybara.string(
      described_class.new(druid: 'oo000oo0000', height: '555', width: '666', purl_object_title: 'The Object Title') do
        'Added Panel Content'
      end.to_html
    )
  end

  context 'block param' do
    it 'instantiates without passing a block' do
      expect { described_class.new(druid: 'oo000oo0000', height: '1', width: '2', purl_object_title: 'a') }.not_to raise_error
    end
    it 'instantiates with an empty block' do
      expect { described_class.new(druid: 'oo000oo0000', height: '1', width: '2', purl_object_title: 'a') {} }.not_to raise_error
    end
    it 'instantiates with a nil block' do
      expect { described_class.new(druid: 'oo000oo0000', height: '1', width: '2', purl_object_title: 'a') { nil } }.not_to raise_error
    end
    it 'instantiates with an empty string block' do
      expect { described_class.new(druid: 'oo000oo0000', height: '1', width: '2', purl_object_title: 'a') { '' } }.not_to raise_error
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
        expect(subject).to have_content('title (The Object Title)')
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
end
