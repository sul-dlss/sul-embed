# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompanionWindows::ContentListComponent, type: :component do
  let(:component) { described_class.new(viewer:) }
  let(:viewer) { instance_double(Embed::Viewer::DocumentViewer, purl_object:) }
  let(:purl_object) do
    instance_double(
      Embed::Purl,
      contents: instance_double(
        Embed::Purl::Resource,
        type: 'document',
        files: [no_download_file, download_file],
        druid: 'abc123'
      ),
      all_resource_files: [no_download_file, download_file]
    )
  end

  let(:no_download_file) do
    instance_double(Embed::Purl::ResourceFile,
                    title: 'doc-abc456.pdf',
                    no_download?: true)
  end

  let(:download_file) do
    instance_double(Embed::Purl::ResourceFile,
                    title: 'doc-abc123.pdf',
                    location_restricted?: true,
                    no_download?: false)
  end

  before do
    render_inline(component)
  end

  it 'renders content list section' do
    expect(page).to have_css('ul#content-list')
  end

  describe '#resource_files_collection' do
    it 'returns a list of all purl objects that do not have no_download? returning true' do
      expect(component.resource_files_collection).to eq([download_file])
    end
  end
end
