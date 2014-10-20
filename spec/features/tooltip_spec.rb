require 'rails_helper'

describe 'tooltip on embargo', js: true do
  include PURLFixtures
  it 'should display when hovering on an embargoed link' do
    stub_purl_response_with_fixture(embargoed_purl)
    send_embed_response
    expect(page).to_not have_css '.sul-embed-tooltip'
    page.find('[data-sul-embed-tooltip="true"]').hover
    pending(page).to have_css '.sul-embed-tooltip', visible: true
  end
end
