# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'IIIF Embed', :js do
  it 'renders a Mirador3 Viewer' do
    visit iiif_path(url: 'https://purl.stanford.edu/fr426cg9537/iiif/manifest')

    expect(page).to have_css('.sul-embed-container', visible: :visible)
    expect(page).to have_css('main.mirador-viewer', visible: :visible)
  end
end
