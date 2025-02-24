# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MediaComponent, type: :component do
  before do
    allow(embed_request).to receive(:purl_object).and_return(purl_object)
    render_inline(described_class.new(viewer:))
  end

  let(:embed_request) { Embed::Request.new({}) }
  let(:viewer) do
    Embed::Viewer::Media.new(embed_request)
  end
  let(:purl_object) do
    instance_double(Embed::Purl,
                    title: 'Sample title',
                    purl_url: 'https://purl.stanford.edu/123',
                    iiif_v3_manifest_url: 'https://purl.stanford.edu/123/iiif/manifest',
                    use_and_reproduction: '',
                    copyright: '',
                    license: '',
                    druid: '123',
                    version_id: nil,
                    contents: [],
                    restricted_location: 'reading room',
                    downloadable_files: [],
                    downloadable_transcript_files?: false)
  end

  it 'displays the page' do
    within 'header' do
      expect(page).to have_content 'Sample title'
    end
    # Accessabile dialog
    within 'dialog' do
      expect(page).to have_content 'To request a transcript or other accommodation'
    end

    # Auth components
    expect(page).to have_content 'Access is restricted to the reading room. See Access conditions for more information.'
    expect(page).to have_content 'Stanford users: log in to access all available features'
    expect(page).to have_content 'Access is restricted until the embargo has elapsed'
  end

  context 'when hide_title is passed' do
    let(:embed_request) { Embed::Request.new(hide_title: 'true') }

    it 'displays the page' do
      within 'header' do
        expect(page).to have_no_content 'Sample title'
      end
    end
  end
end
