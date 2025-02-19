# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompanionWindowsComponent, type: :component do
  subject(:companion_windows_component) { described_class.new(viewer:) }

  before do
    allow(embed_request).to receive(:purl_object).and_return(purl_object)
    render_inline(companion_windows_component)
  end

  let(:embed_request) { Embed::Request.new({}) }
  let(:viewer) do
    Embed::Viewer::Media.new(embed_request)
  end

  let(:downloadable_files) { [] }
  let(:purl_object) do
    instance_double(Embed::Purl,
                    title: 'foo',
                    purl_url: 'https://purl.stanford.edu/123',
                    manifest_json_url: 'https://purl.stanford.edu/123/iiif/manifest',
                    use_and_reproduction: '',
                    copyright: '',
                    license: '',
                    druid: '123',
                    version_id: nil,
                    contents: [],
                    downloadable_files:,
                    downloadable_transcript_files?: false)
  end

  it 'displays the page' do
    expect(page).to have_content 'About this item'
    expect(page).to have_content 'Contents'
    expect(page).to have_content 'Rights'
  end
end
