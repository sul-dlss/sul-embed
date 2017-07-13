require 'rails_helper'

RSpec.describe 'embed/metadata/_image_x.html.erb' do
  include PURLFixtures

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:object) { Embed::PURL.new('12345') }
  let(:viewer) { Embed::Viewer::ImageX.new(request) }

  before do
    view.lookup_context.view_paths.push 'app/views/embed'
    allow(request).to receive(:purl_object).and_return(object)
    allow(object).to receive(:response).and_return(image_purl)
    allow(view).to receive(:viewer).and_return(viewer)
    stub_template 'metadata/_iiif_drag_and_drop_icon.html.erb' => 'Icon'
    render
  end

  it 'does not have use and reproduction when not in object' do
    expect(rendered).to_not have_content 'Use and reproduction'
  end
  it 'has copyright' do
    expect(rendered).to have_content 'Copyright'
  end
  it 'does not have license when not in object' do
    expect(rendered).to_not have_content 'License'
  end
end
