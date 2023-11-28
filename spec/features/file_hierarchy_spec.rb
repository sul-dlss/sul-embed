# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'file viewer with hierarchy', :js do
  let(:contents) do
    [
      build(:resource, files: [build(:resource_file, filename: 'Title_of_the_PDF.pdf')]),
      build(:resource, files: [build(:resource_file, filename: 'dir1/dir2/Title_of_2_PDF.pdf')])
    ]
  end
  let(:purl) { build(:purl, :file, contents:) }

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
  end

  it 'renders hierarchy' do
    visit_iframe_response
    expect(page).to have_content('2 items')
    # There are 2 files
    expect(page).to have_css('.sul-embed-media', count: 2)
    # There are 2 directories
    expect(page).to have_css('.sul-embed-treeitem', count: 2)
    # One of the files is nested
    expect(page).to have_css('[role="treeitem"] [role="treeitem"] [role="treeitem"] .sul-embed-media', count: 1)
    # Does not render indexes
    all('.sul-embed-count').each do |count_elem|
      expect(count_elem).not_to have_content('1')
    end

    all('[role="treeitem"]')[3].click
    expect(page).to have_css('.sul-embed-media', count: 1)
    all('[role="treeitem"][aria-expanded="false"]').first.click
    expect(page).to have_css('.sul-embed-media', count: 2)
  end
end
