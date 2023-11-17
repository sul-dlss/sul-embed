# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Download::LegacyMediaComponent, type: :component do
  include PurlFixtures

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:object) { Embed::Purl.new('12345') }
  let(:viewer) { Embed::Viewer::Media.new(request) }
  let(:response) { video_purl }

  before do
    allow(request).to receive(:purl_object).and_return(object)
    # allow(viewer).to receive(:asset_host).and_return('http://example.com/')
    allow(object).to receive(:response).and_return(response)
    render_inline(described_class.new(viewer:))
  end

  context 'when show_download? is false' do
    let(:object) { instance_double(Embed::Purl, downloadable_files: []) } # .new('12345') }

    it 'renders nothing' do
      expect(page).not_to have_css('body')
    end
  end

  context 'when downloadable files' do
    let(:response) { video_purl }

    it 'uses the label as the link text' do
      expect(page).to have_css('li a', text: 'Download Transcript', visible: :all)
    end

    it 'includes the file sizes when present' do
      expect(page).to have_css('li', text: /\(\d+\.\d+ MB\)/, visible: :all)
      expect(page).to have_css('li', text: /\(\d+\.\d+ kB\)/, visible: :all)
    end

    it 'includes attributes appropriate for _blank target download links' do
      expect(page).to have_css('li a[target="_blank"][rel="noopener noreferrer"]', count: 3, visible: :all)
    end

    it 'includes download=true param' do
      expect(page).to have_css 'li a[href*="?download=true"]', count: 3, visible: :all
    end

    it 'includes downloadable files' do
      expect(page).to have_content 'Download item'
      expect(page).to have_content 'Download Second Video'
      expect(page).to have_content 'Download Transcript'
    end

    it 'does not include files with no-download rule' do
      expect(page).not_to have_content('Download Tape 1')
    end

    it 'does not include files with read location restricted' do
      expect(page).not_to have_content 'Download abc_123.mp4'
    end

    context 'when rights are Stanford only' do
      let(:response) { stanford_restricted_file_purl_xml }

      it 'has a span with a stanford-only s icon class (with screen-reader text)' do
        expect(page).to have_css('.sul-embed-stanford-only-text', visible: :all)
        expect(page).to have_css('.sul-embed-text-hide', text: 'Stanford only', visible: :all)
      end
    end

    context 'when the resource is location restricted' do
      let(:response) { single_video_purl }

      it 'not included in download panel' do
        expect(page).not_to have_css('body')
      end
    end
  end
end
