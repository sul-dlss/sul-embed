# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::FooterComponent, type: :component do
  include PurlFixtures

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:object) { Embed::Purl.new('12345') }
  let(:viewer) { Embed::Viewer::Geo.new(request) }

  before do
    allow(request).to receive(:purl_object).and_return(object)
    allow(object).to receive(:response).and_return(image_purl_xml)
    render_inline(described_class.new(viewer:))
  end

  it "returns the object's footer" do
    expect(page).to have_css 'div.sul-embed-footer'
    expect(page).to have_css '[aria-label="open embed this panel"]'
    expect(page).to have_css '[aria-label="2 files available for download"]'
  end

  describe 'fullscreen button' do
    context 'when the viewer is configured to use the local fullscreen function' do
      let(:viewer) { Embed::Viewer::PdfViewer.new(request) }

      it { expect(page).to have_css('button#full-screen-button') }
    end

    context 'when the viewer is not configured to use the local fullscreen function' do
      it { expect(page).not_to have_css('button#full-screen-button') }
    end
  end
end
