# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'embed/header/_file' do
  include PurlFixtures

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:object) { Embed::Purl.new('12345') }
  let(:viewer) { Embed::Viewer::File.new(request) }

  before do
    view.lookup_context.view_paths.push 'app/views/embed'
    allow(request).to receive(:purl_object).and_return(object)
    allow(object).to receive(:response).and_return(file_purl)
    allow(view).to receive(:viewer).and_return(viewer)
  end

  it "returns the object's title" do
    render
    expect(rendered).to have_css '.sul-embed-header-title', text: 'File Title'
  end

  context 'with hide_title' do
    before do
      allow(request).to receive(:hide_title?).at_least(:once).and_return(true)
    end
    it 'does not return the object title if the consumer requested to hide it' do
      render
      expect(rendered).to_not have_css '.sul-embed-header-title'
      expect(rendered).to_not have_css '.sul-embed-metadata-title'
    end
  end
end
