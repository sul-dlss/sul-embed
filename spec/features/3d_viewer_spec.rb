# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '3D Viewer', :js do
  let(:purl) { build(:purl, :model_3d) }

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
    visit_iframe_response
  end

  it 'renders the 3D viewer for 3D objects' do
    expect(page).to have_css('.sul-embed-3d model-viewer')
  end

  it 'has working panels' do
    expect(page).to have_no_content('About this item')
    page.find('[aria-controls="left-drawer"]').click
    expect(page).to have_content('About this item')
  end
end
