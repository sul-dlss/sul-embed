# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Media::EmbedThisFormComponent, type: :component do
  let(:request) do
    Embed::Request.new(url: 'http://purl.stanford.edu/abc123')
  end
  let(:object) do
    instance_double(Embed::Purl, title: '', druid: '', all_resource_files: [], embargoed?: false, purl_url: 'https://stanford.edu/')
  end
  let(:viewer) { Embed::Viewer::File.new(request) }

  before do
    allow(request).to receive(:purl_object).and_return(object)
    render_inline(described_class.new(viewer:))
  end

  it 'has the form elements for updating the embed code' do
    expect(page).to have_content('Select options:')
    expect(page).to have_css('input#sul-embed-embed-title[type="checkbox"]')
    expect(page).to have_css('input#sul-embed-embed[type="checkbox"]')
    expect(page).to have_css('textarea#sul-embed-iframe-code')
  end
end
