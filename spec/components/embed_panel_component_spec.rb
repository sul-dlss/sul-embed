# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmbedPanelComponent, type: :component do
  before do
    render_inline(described_class.new(viewer:)) { 'Added Panel Content' }
  end

  let(:embed_request) { Embed::Request.new({ url: 'http://purl.stanford.edu/abc123' }) }
  let(:viewer) do
    instance_double(
      Embed::Viewer::CommonViewer,
      height: '555',
      width: '666',
      embed_request:,
      iframe_title: 'File viewer',
      purl_object: instance_double(Embed::Purl, druid: 'oo000oo0000', title: 'The Object Title', purl_url: 'https://stanford.edu/')
    )
  end

  describe 'header' do
    it 'has the panel title' do
      expect(page).to have_css(
        '.sul-embed-panel-header .sul-embed-panel-title',
        text: 'Embed',
        visible: :all
      )
    end
  end

  describe 'body' do
    describe 'title' do
      it 'has the purl object title' do
        expect(page).to have_content(/title\s*\(The Object Title\)/)
      end

      it 'has span with only the purl object title' do
        expect(page).to have_css(
          'span',
          text: '(The Object Title)',
          visible: :all
        )
      end

      it 'has hide_title checkbox' do
        expect(page).to have_css('input#sul-embed-embed-title[data-embed-attr=hide_title][type=checkbox]', visible: :all)
      end
    end

    it 'includes the content provided in the block' do
      expect(page).to have_content('Added Panel Content')
    end

    it 'has hide embed checkbox' do
      expect(page).to have_css('input#sul-embed-embed[data-embed-attr=hide_embed][type=checkbox]', visible: :all)
    end

    it 'has iframe textarea' do
      # more specific tests in feature
      expect(page).to have_css('textarea#sul-embed-iframe-code', visible: :all)
    end
  end
end
