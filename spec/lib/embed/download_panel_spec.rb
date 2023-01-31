# frozen_string_literal: true

require 'rails_helper'
require 'embed/download_panel'
RSpec.describe Embed::DownloadPanel do
  subject do
    Capybara.string(
      described_class.new(title: 'The Panel Title') do
        'Added Panel Content'
      end.to_html
    )
  end

  describe 'header' do
    it 'has the panel title' do
      expect(subject).to have_css(
        '.sul-embed-panel-header .sul-embed-panel-title',
        text: 'The Panel Title',
        visible: :all
      )
    end
  end

  describe 'content' do
    it 'includes the content provided in the block' do
      expect(subject).to have_content('Added Panel Content')
    end
  end
end
