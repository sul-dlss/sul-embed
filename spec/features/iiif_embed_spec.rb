# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'IIIF Embed', :js do
  before do
    stub_request(:get, 'https://purl.stanford.edu/fr426cg9537.xml')
      .to_return(status: 200, body: '', headers: {})
  end

  it 'renders a Mirador Viewer' do
    visit iiif_path(url: 'https://purl.stanford.edu/fr426cg9537/iiif/manifest')

    debugger

    expect(page).to have_css('.sul-embed-container', visible: :visible)
    # TODO: failing
    expect(page).to have_css('main.mirador-viewer', visible: :visible)
  end

  it 'sets the enable-comparison data attribute when enable_comparison is requested' do
    visit iiif_path(url: 'https://purl.stanford.edu/fr426cg9537/iiif/manifest', enable_comparison: 'true')

    expect(page).to have_css('[data-enable-comparison="true"]')
  end
end
