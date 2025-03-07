# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'metadata panel', :js, skip: 'legacy only' do
  let(:request) do
    Embed::Request.new(
      { url: 'http://purl.stanford.edu/abc123' },
      controller
    )
  end

  let(:purl) do
    build(:purl, :file,
          contents: [build(:resource, files: [build(:resource_file, :document, label: 'File1 Label')])],
          use_and_reproduction: 'You can use this.',
          license: 'Public Domain Mark 1.0')
  end

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
    visit_iframe_response
  end

  it 'is present after a user clicks the button' do
    expect(page).to have_css('.sul-embed-metadata-panel', visible: :hidden)
    page.find('[data-sul-embed-toggle="sul-embed-metadata-panel"]', match: :first).click
    expect(page).to have_css('.sul-embed-metadata-panel', visible: :all)
    page.find('[data-sul-embed-toggle="sul-embed-metadata-panel"]', match: :first).click
    expect(page).to have_css('.sul-embed-metadata-panel', visible: :hidden)
  end

  it 'has purl link, use and reproduction, and license text' do
    page.find('[data-sul-embed-toggle="sul-embed-metadata-panel"]', match: :first).click
    expect(page).to have_css('dt', text: 'Citation URL', visible: :all)
    expect(page).to have_css('dt', text: 'Use and reproduction', visible: :all)
    expect(page).to have_css('dt', text: 'License', visible: :all)
    within '.sul-embed-metadata-panel' do
      expect(page).to have_css 'dd', text: 'You can use this.', visible: :all
    end
  end
end
