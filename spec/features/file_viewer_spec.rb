# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'File viewer', :js do
  include PurlFixtures
  let(:fixture) { file_purl_xml }

  before do
    stub_purl_xml_response_with_fixture(fixture)
  end

  context 'with no options' do
    before do
      visit_iframe_response
    end

    it 'makes purl embed request and embed' do
      expect(page).to have_css('.sul-embed-container')
      expect(page).to have_css('.sul-embed-header')
      expect(page).to have_css('.sul-embed-header-title')
      expect(page).to have_css('.sul-embed-body')
      expect(page).to have_css('.sul-embed-footer')
      expect(page).to have_css('.sul-embed-file-list')
      expect(page).to have_css('.sul-embed-media-list')

      expect(page).to have_css('.sul-embed-media-heading a', text: 'Title of the PDF.pdf')
      expect(page).to have_css('.sul-embed-description', text: 'File1 Label')
      expect(page).to have_css('.sul-embed-download', text: '12.34 kB')
    end

    context 'when the object has multiple files' do
      let(:fixture) { multi_resource_multi_type_purl }

      it 'contains 4 files in file list' do
        expect(page).to have_css 'img.sul-embed-square-image[alt]', visible: :all
        expect(page).to have_css('.sul-embed-count', count: 4)
      end
    end
  end

  context 'when hide_title is requested' do
    before do
      visit_iframe_response('abc123', hide_title: true)
    end

    it 'hides the title' do
      expect(page).not_to have_css('.sul-embed-header-title')
    end
  end
end
