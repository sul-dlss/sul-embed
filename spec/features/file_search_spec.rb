# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'file viewer search bar', :js do
  let(:purl) do
    build(:purl, :file,
          contents: [build(:resource, files: [build(:resource_file, :document, label: 'File1 Label')])])
  end

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
  end

  context 'when text is entered with a file list' do
    it 'limits shown files' do
      visit_iframe_response('abc123', min_files_to_search: 1)
      expect(page).to have_css('tr[data-tree-role="leaf"]', count: 1)
      expect(page).to have_css '.item-count', text: '1 file'
      fill_in 'Search this list', with: 'test'
      expect(page).to have_no_css('tr[data-tree-role="leaf"]')
      expect(page).to have_css '.item-count', text: '0 files'
      fill_in 'Search this list', with: 'File1'
      expect(page).to have_css '.item-count', text: '1 file'
    end
  end

  context 'when text is entered with a hierarchical file list' do
    let(:contents) do
      [
        build(:resource, files: [build(:resource_file, filename: 'Title_of_the_PDF.pdf')]),
        build(:resource, files: [build(:resource_file, filename: 'dir1/dir2/Title_of_2_PDF.pdf')])
      ]
    end
    let(:purl) { build(:purl, :file, contents:) }

    it 'hides empty directories' do
      visit_iframe_response('abc123', min_files_to_search: 1)
      expect(page).to have_css '.item-count', text: '2 files'
      expect(page).to have_content('dir1')
      expect(page).to have_content('dir2')
      expect(page).to have_content('Title_of_2_PDF')
      expect(page).to have_content('Title_of_the_PDF')

      fill_in 'Search this list', with: 'Title_of_the_PDF'
      expect(page).to have_no_content('dir1')
      expect(page).to have_no_content('dir2')
      expect(page).to have_no_content('Title_of_2_PDF')
      expect(page).to have_content('Title_of_the_PDF')

      expect(page).to have_css '.item-count', text: '1 file'
    end
  end

  context 'when the number of files are beneath the threshold' do
    it 'does not display the search box' do
      visit_iframe_response
      expect(page).to have_no_css('.sul-embed-search-input')
    end

    it 'hides the search box when requested' do
      visit_iframe_response('abc123', hide_search: true)
      expect(page).to have_no_css('.sul-embed-search')
    end
  end
end
