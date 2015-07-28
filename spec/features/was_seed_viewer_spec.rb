require 'rails_helper'
include PURLFixtures

describe 'was seed viewer public', js: true do
  before do
    stub_purl_response_with_fixture(was_seed_purl)
    visit_sandbox
    fill_in_default_sandbox_form
    click_button 'Embed'
  end
end
