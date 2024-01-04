# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::File::HeaderComponent, type: :component do
  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:viewer) { Embed::Viewer::File.new(request) }

  let(:purl) { build(:purl, title: 'File Title') }

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
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
      expect(page).to have_no_css '.sul-embed-header-title'
      expect(page).to have_no_css '.sul-embed-metadata-title'
    end
  end
end
