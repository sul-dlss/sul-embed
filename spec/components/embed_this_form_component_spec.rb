# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EmbedThisFormComponent, type: :component do
  let(:request) do
    Embed::Request.new(url: 'http://purl.stanford.edu/abc123')
  end
  let(:object) do
    instance_double(Embed::Purl, title: '', druid: '', version_id: nil, resource_files: [], embargoed?: false, purl_url: 'https://stanford.edu/')
  end
  let(:viewer) { Embed::Viewer::CommonViewer.new(request) }

  before do
    allow(request).to receive(:purl_object).and_return(object)
    render_inline(described_class.new(viewer:))
  end

  it 'has the form elements for updating the embed code' do
    expect(page).to have_content('Select options:')
    expect(page).to have_css('input#sul-embed-embed-title[type="checkbox"]')
    expect(page).to have_css('input#sul-embed-embed[type="checkbox"]')
    expect(page).to have_css('textarea#sul-embed-iframe-code')
    expect(page).to have_css('button.copy-to-clipboard')
  end

  context 'with a file viewer' do
    let(:viewer) { Embed::Viewer::File.new(request) }

    it 'has the form elements for updating the embed code' do
      expect(page).to have_checked_field('add search box', visible: :all)
      expect(page).to have_field('sul-embed-min_files_to_search', with: '10', visible: :all)
    end
  end
end
