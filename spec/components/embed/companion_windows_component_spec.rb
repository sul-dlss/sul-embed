# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::CompanionWindowsComponent, type: :component do
  subject(:companion_windows_component) { described_class.new(viewer:) }

  before do
    allow(embed_request).to receive(:purl_object).and_return(purl_object)
    render_inline(companion_windows_component)
  end

  let(:embed_request) { Embed::Request.new({}) }
  let(:viewer) do
    Embed::Viewer::Media.new(embed_request)
  end
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
                    downloadable_files: [],
                    downloadable_transcript_files?: false)
  end

  it 'displays the page' do
    expect(page).to have_content 'About this item'
    expect(page).to have_content 'Media content'
    expect(page).to have_content 'Rights'
  end

  describe 'requested_by_chromium?' do
    before { vc_test_request.headers['User-Agent'] = user_agent_string }

    context 'with a realistic sample Firefox user agent string' do
      let(:user_agent_string) { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:127.0) Gecko/20100101 Firefox/127.0' }

      it 'returns false' do
        expect(companion_windows_component.requested_by_chromium?).to be false
      end
    end

    context 'with a realistic sample Chrome user agent string' do
      let(:user_agent_string) { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36' }

      it 'returns true' do
        expect(companion_windows_component.requested_by_chromium?).to be true
      end
    end

    context 'with a realistic sample Edge user agent string' do
      let(:user_agent_string) { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 Edg/126.0.0.0' }

      it 'returns true' do
        expect(companion_windows_component.requested_by_chromium?).to be true
      end
    end
  end
end
