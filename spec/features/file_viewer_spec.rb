# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'File viewer', :js do
  let(:purl) do
    build(:purl, :file, contents: [build(:resource, files: [build(:resource_file, :document, label: 'File1 Label')])])
  end

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
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

      expect(page).to have_css('tr[data-tree-role="leaf"] a', text: 'Download')
      expect(page).to have_css('*[data-tree-role="label"]', text: 'File1 Label')
      expect(page).to have_css('td', text: '12.34 kB')
    end

    context 'when the object has multiple files' do
      let(:purl) do
        build(:purl, :file, contents: [
                build(:resource, :file, files: [build(:resource_file), build(:resource_file)]),
                build(:resource, :image),
                build(:resource, :file, files: [build(:resource_file)])
              ])
      end

      it 'contains 4 files in file list' do
        expect(page).to have_css('tr[data-tree-role="leaf"]', count: 4)
      end
    end
  end

  context 'when hide_title is requested' do
    before do
      visit_iframe_response('abc123', hide_title: true)
    end

    it 'hides the title' do
      expect(page).to have_no_css('.sul-embed-header-title')
    end
  end
end
