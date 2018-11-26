# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'embed/download/_media.html.erb' do
  include PURLFixtures

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:object) { Embed::PURL.new('12345') }
  let(:viewer) { Embed::Viewer::Media.new(request) }
  let(:response) { video_purl }
  before do
    view.lookup_context.view_paths.push 'app/views/embed'
    allow(request).to receive(:purl_object).and_return(object)
    allow(viewer).to receive(:asset_host).and_return('http://example.com/')
    allow(view).to receive(:viewer).and_return(viewer)
    allow(object).to receive(:response).and_return(response)
  end

  it 'empty string when show_download? is false' do
    expect(viewer).to receive(:show_download?).and_return false
    render
    expect(rendered).to eq ''
  end
  context 'when downloadable files' do
    let(:response) { video_purl }
    before { render }

    it 'uses the label as the link text when present' do
      expect(rendered).to have_css('li a', text: 'Download Transcript', visible: false)
      expect(rendered).not_to have_css('li a', text: 'Download abc_123_script.pdf', visible: false)
    end

    it 'uses the file id as the link text when no label present' do
      expect(rendered).to have_css('li a', text: 'Download abc_333.mp4', visible: false)
    end

    it 'includes the file sizes when present' do
      expect(rendered).to have_css('li', text: /\(\d+\.\d+ MB\)/, visible: false)
      expect(rendered).to have_css('li', text: /\(\d+\.\d+ kB\)/, visible: false)
    end

    it 'includes attributes appropriate for _blank target download links' do
      expect(rendered).to have_css('li a[target="_blank"][rel="noopener noreferrer"]', count: 3, visible: false)
    end

    it 'includes download=true param' do
      expect(rendered).to have_css 'li a[href*="?download=true"]', count: 3, visible: false
    end

    it 'includes downloadable files' do
      expect(rendered).to have_content 'Download item'
      expect(rendered).to have_content 'Download Second Video'
      expect(rendered).to have_content 'Download Transcript'
    end

    it 'does not include files with no-download rule' do
      expect(rendered).not_to have_content('Download Tape 1')
    end

    it 'does not include files with read location restricted' do
      expect(rendered).not_to have_content 'Download abc_123.mp4'
    end

    context 'Stanford only' do
      let(:response) { stanford_restricted_file_purl }
      it 'has a span with a stanford-only s icon class (with screen-reader text)' do
        expect(rendered).to have_css('.sul-embed-stanford-only-text', visible: false)
        expect(rendered).to have_css('.sul-embed-text-hide', text: 'Stanford only', visible: false)
      end
    end

    context 'Location restricted' do
      let(:response) { single_video_purl }

      it 'not included in download panel' do
        expect(rendered).to eq ''
      end
    end
  end
end
