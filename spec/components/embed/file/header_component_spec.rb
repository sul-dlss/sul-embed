# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::File::HeaderComponent, type: :component do
  include PurlFixtures

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:object) { Embed::Purl.new('12345') }
  let(:viewer) { Embed::Viewer::File.new(request) }

  before do
    allow(request).to receive(:purl_object).and_return(object)
    allow(object).to receive(:response).and_return(file_purl_xml)
    render_inline(described_class.new(viewer:))
  end

  it "returns the object's title" do
    expect(page).to have_css '.sul-embed-header-title', text: 'File Title'
  end

  context 'with hidden title' do
    let(:request) do
      Embed::Request.new(url: 'http://purl.stanford.edu/abc123', hide_title: 'true')
    end

    it 'does not return the object title if the consumer requested to hide it' do
      expect(page).not_to have_css '.sul-embed-header-title'
      expect(page).not_to have_css '.sul-embed-metadata-title'
    end
  end
end
