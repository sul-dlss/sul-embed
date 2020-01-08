# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'embed/footer/_generic.html.erb' do
  include PURLFixtures

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:object) { Embed::PURL.new('12345') }
  let(:viewer) { Embed::Viewer::Geo.new(request) }

  before do
    view.lookup_context.view_paths.push 'app/views/embed'
    allow(request).to receive(:purl_object).and_return(object)
    allow(object).to receive(:response).and_return(image_purl)
    allow(view).to receive(:viewer).and_return(viewer)
    render
  end

  it "returns the object's footer" do
    expect(rendered).to have_css 'div.sul-embed-footer'
    expect(rendered).to have_css '[aria-label="open embed this panel"]'
    expect(rendered).to have_css '[aria-label="open download panel"]'
  end

  describe 'fullscreen button' do
    context 'when the viewer is configured to use the local fullscreen function' do
      let(:viewer) { Embed::Viewer::PDFViewer.new(request) }

      it { expect(rendered).to have_css('button#full-screen-button') }
    end

    context 'when the viewer is not configured to use the local fullscreen function' do
      it { expect(rendered).not_to have_css('button#full-screen-button') }
    end
  end
end
