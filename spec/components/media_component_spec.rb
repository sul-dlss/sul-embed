# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MediaComponent, type: :component do
  before do
    allow(embed_request).to receive(:purl_object).and_return(purl_object)
    render_inline(described_class.new(viewer:))
  end

  let(:downloadable_caption_files) { true }
  let(:downloadable_files) { [] }
  let(:embed_request) { Embed::Request.new({}) }
  let(:viewer) do
    Embed::Viewer::Media.new(embed_request)
  end
  let(:purl_object) do
    instance_double(Embed::Purl,
                    title: 'Sample title',
                    purl_url: 'https://purl.stanford.edu/123',
                    manifest_json_url: 'https://purl.stanford.edu/123/iiif3/manifest',
                    use_and_reproduction: '',
                    copyright: '',
                    license: '',
                    druid: '123',
                    version_id: nil,
                    contents: [],
                    restricted_location: 'reading room',
                    downloadable_files:,
                    downloadable_caption_files?: :downloadable_caption_files,
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

    # Auth component
    expect(page).to have_content 'Stanford users: log in to access all available features'

    within '.sul-embed-container' do
      click_on 'Toggle sidebar'
      expect(page).to have_css('[aria-label="Transcript"]', visible: :visible)
    end
  end

  context 'when it has stanford only caption files' do
    let(:downloadable_files) { [instance_double(Embed::Purl::MediaFile, caption?: true, stanford_only?: true)] }

    it 'displays transcript sidebar with login message' do
      expect(page).to have_css('[aria-label="Transcript"]', visible: :all)
      expect(page).to have_content('Login in to view transcript')
    end
  end

  context 'when it does not have caption files' do
    let(:downloadable_caption_files?) { false }

    it 'does not display transcript sidebar' do
      expect(page).to have_css('[aria-label="Transcript"]', visible: :hidden)
    end
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
