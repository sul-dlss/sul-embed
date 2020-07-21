# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'embed/download/_geo.html.erb' do
  include PurlFixtures

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:object) { Embed::Purl.new('12345') }
  let(:viewer) { Embed::Viewer::Geo.new(request) }
  let(:response) { geo_purl_public }
  before do
    view.lookup_context.view_paths.push 'app/views/embed'
    allow(request).to receive(:purl_object).and_return(object)
    allow(viewer).to receive(:asset_host).and_return('http://example.com/')
    allow(view).to receive(:viewer).and_return(viewer)
    allow(object).to receive(:response).and_return(response)
    render
  end

  context 'when hide_download' do
    let(:viewer) do
      Embed::Viewer::Geo.new(
        Embed::Request.new(
          url: 'http://purl.stanford.edu/abc123', hide_download: 'true'
        )
      )
    end
    it 'is empty' do
      expect(rendered).to eq ''
    end
  end

  it 'generates a file list when file has resources' do
    expect(rendered).to have_css 'li', visible: false, count: 3
    expect(rendered).to have_css 'a[href="https://stacks.stanford.edu/file/druid:12345/data.zip?download=true"]', visible: false
  end

  context 'with stanford only' do
    let(:response) { stanford_restricted_multi_file_purl }
    it 'has the stanford-only class (with screen reader text)' do
      expect(rendered).to have_css 'li .sul-embed-stanford-only-text .sul-embed-text-hide', text: 'Stanford only', visible: false
    end
  end

  context 'with location restrictions' do
    let(:response) { single_video_purl }
    it 'includes text to indicate that they are restricted' do
      expect(rendered).to have_css 'li .sul-embed-location-restricted-text', text: '(Restricted)', visible: false
    end
  end
end
