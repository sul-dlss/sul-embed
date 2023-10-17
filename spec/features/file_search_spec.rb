# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'file viewer search bar', :js do
  include PurlFixtures

  context 'when text is entered with a file list' do
    it 'limits shown files' do
      stub_purl_response_with_fixture(file_purl)
      visit_iframe_response('abc123', min_files_to_search: 1)
      expect(page).to have_css('.sul-embed-count', count: 1)
      expect(page).to have_css '.sul-embed-item-count', text: '1 item'
      fill_in 'Search this list', with: 'test'
      expect(page).not_to have_css('.sul-embed-count')
      expect(page).to have_css '.sul-embed-item-count', text: '0 items'
      fill_in 'Search this list', with: 'File1'
      expect(page).to have_css '.sul-embed-item-count', text: '1 item'
    end
  end

  context 'when text is entered with a hierarchical file list' do
    it 'hides empty directories' do
      stub_purl_response_with_fixture(hierarchical_file_purl)
      visit_iframe_response('abc123', min_files_to_search: 1)
      expect(page).to have_css '.sul-embed-item-count', text: '2 items'
      expect(page).to have_content('dir1')
      expect(page).to have_content('dir2')
      expect(page).to have_content('Title_of_2_PDF')
      expect(page).to have_content('Title_of_the_PDF')

      fill_in 'Search this list', with: 'Title_of_the_PDF'
      expect(page).not_to have_content('dir1')
      expect(page).not_to have_content('dir2')
      expect(page).not_to have_content('Title_of_2_PDF')
      expect(page).to have_content('Title_of_the_PDF')

      expect(page).to have_css '.sul-embed-item-count', text: '1 item'
    end
  end

  context 'when the number of files are beneath the threshold' do
    it 'does not display the search box' do
      stub_purl_response_with_fixture(file_purl)
      visit_iframe_response
      expect(page).not_to have_css('.sul-embed-search-input')
    end

    it 'hides the search box when requested' do
      stub_purl_response_with_fixture(file_purl)
      visit_iframe_response('abc123', hide_search: true)
      expect(page).not_to have_css('.sul-embed-search')
    end
  end
end
