require 'rails_helper'

RSpec.describe 'embed/template/_image_x.html.erb' do
  include PURLFixtures

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:object) { Embed::PURL.new('12345') }
  let(:viewer) { Embed::Viewer::ImageX.new(request) }

  before do
    view.lookup_context.view_paths.push 'app/views/embed'
    allow(request).to receive(:purl_object).and_return(object)
    allow(viewer).to receive(:asset_host).and_return('http://example.com/')
    allow(view).to receive(:viewer).and_return(viewer)
  end

  context 'regular image' do
    before do
      allow(object).to receive(:response).and_return(image_purl)
      render
    end

    it 'should return imageX viewer body' do
      # visible false because we display:none the container until we've loaded the CSS.
      expect(rendered).to have_css '.sul-embed-image-x', visible: false
      expect(rendered).to have_css('#sul-embed-image-x[data-manifest-url=\'https://purl.stanford.edu/12345/iiif/manifest\']', visible: false)
      expect(rendered).to have_css('.sul-embed-image-x-buttons button[aria-label]', count: 4, visible: false)
      expect(rendered).to have_css('#sul-embed-image-x[data-world-restriction=false]', visible: false)
    end
  end

  context 'PDF' do
    before do
      allow(object).to receive(:response).and_return(image_with_pdf_purl)
      render
    end

    it 'shows download links' do
      expect(rendered).to have_css '.sul-embed-download-list-full', visible: false
      expect(rendered).to have_css 'ul li div a', visible: false, text: /Download "Writings - 'How to  ..." \(as pdf\)\s+4\.76 MB/
    end
  end

  context 'with a restricted PDF' do
    before do
      allow(object).to receive(:response).and_return(image_with_pdf_restricted_purl)
      render
    end
    it 'shows as restricted with proper target and rel attributes' do
      expect(rendered).to have_css 'ul li div.sul-embed-stanford-only a[target="_blank"][rel="noopener noreferrer"]', visible: false, text: 'Download "Yolo" (as pdf)'
    end
  end
end
