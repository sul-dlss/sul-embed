# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Download::LegacyMediaComponent, type: :component do
  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:viewer) { Embed::Viewer::Media.new(request) }
  let(:purl) { build(:purl, contents: resources) }
  let(:resources) { [] }

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
  end

  context 'when show_download? is false' do
    before do
      allow(purl).to receive(:downloadable_files).and_return([])
      render_inline(described_class.new(viewer:))
    end

    it 'renders nothing' do
      expect(page).not_to have_css('body')
    end
  end

  context 'when downloadable files are present' do
    let(:resources) do
      [
        build(:resource, :video, files: [build(:resource_file, :video, :location_restricted, label: 'First Video')]),
        build(:resource, :video, files: [build(:resource_file, :video, :stanford_only, label: 'Second Video')]),
        build(:resource, :file, files: [build(:resource_file, :document, :world_downloadable, label: 'Transcript')]),
        build(:resource, :video, files: [build(:resource_file, :video, :world_downloadable)])
      ]
    end

    before do
      render_inline(described_class.new(viewer:))
    end

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
      let(:resources) do
        [build(:resource, :file, files: [build(:resource_file, :document, :stanford_only)])]
      end

      it 'has a span with a stanford-only s icon class (with screen-reader text)' do
        expect(page).to have_css('.sul-embed-stanford-only-text', visible: :all)
        expect(page).to have_css('.sul-embed-text-hide', text: 'Stanford only', visible: :all)
      end
    end

    context 'when the resource is location restricted' do
      let(:resources) do
        [build(:resource, :video, files: [build(:resource_file, :video, :location_restricted)])]
      end

      it 'not included in download panel' do
        expect(page).not_to have_css('body')
      end
    end
  end
end
