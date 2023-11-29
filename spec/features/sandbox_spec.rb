# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'embed sandbox page', :js do
  let(:purl) do
    build(:purl, :file, contents: [build(:resource, files: [build(:resource_file, :document, label: 'File1 Label')])])
  end

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
    visit page_path(id: 'sandbox')
  end

  it 'passes the customization URL parameters down to the iframe successfully' do
    expect(page).not_to have_css('iframe')
    check('hide-title')
    check('hide-search')
    fill_in 'api-endpoint', with: embed_path
    fill_in 'url-scheme', with: 'http://purl.stanford.edu/abc123'
    click_button 'Embed'
    iframe_src = page.find('iframe')['src']
    expect(iframe_src).to match(/hide_title=true/)
    expect(iframe_src).to match(/hide_search=true/)
  end
end
