require 'rails_helper'

describe 'imageX viewer', js: true do
  include PURLFixtures
  before do
    stub_purl_response_with_fixture(image_purl)
    visit_sandbox
    fill_in_default_sandbox_form
    click_button 'Embed'
  end
end
