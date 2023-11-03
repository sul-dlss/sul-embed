# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::MediaWithCompanionWindowsComponent, type: :component do
  before do
    allow(embed_request).to receive(:purl_object).and_return(purl_object)
    render_inline(described_class.new(viewer:))
  end

  let(:embed_request) { Embed::Request.new({}) }
  let(:viewer) do
    Embed::Viewer::Media.new(embed_request)
  end
  let(:purl_object) do
    instance_double(Embed::Purl,
                    title: 'foo',
                    purl_url: 'https://purl.stanford.edu/123',
                    use_and_reproduction: '',
                    copyright: '',
                    license: '',
                    druid: '123',
                    contents: [],
                    downloadable_files: [])
  end

  it 'displays hidden auth messages' do
    expect(page).to have_content 'Access is restricted to the reading room. See Access conditions for more information.'
    expect(page).to have_content 'Stanford users: log in to access all available features'
    expect(page).to have_content 'Access is restricted until the embargo has elapsed'
  end
end
