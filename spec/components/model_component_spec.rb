# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModelComponent, type: :component do
  let(:request) do
    Embed::Request.new(url: 'http://purl.stanford.edu/abc123')
  end
  let(:viewer) { Embed::Viewer::ModelViewer.new(request) }
  let(:purl) { build(:purl, :model_3d) }

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)

    render_inline(described_class.new(viewer:))
  end

  it 'draws model-viewer' do
    # visible false because we display:none the container until we've loaded the CSS.
    expect(page).to have_css 'model-viewer', visible: :all
    expect(page).to have_button '+', visible: :all
    expect(page).to have_button '-', visible: :all
  end
end
