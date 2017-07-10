require 'rails_helper'

RSpec.describe 'embed/metadata/_media.html.erb' do
  include PURLFixtures

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:object) { Embed::PURL.new('12345') }
  let(:viewer) { Embed::Viewer::Media.new(request) }

  before do
    view.lookup_context.view_paths.push 'app/views/embed'
    allow(request).to receive(:purl_object).and_return(object)
    allow(object).to receive(:response).and_return(video_purl)
    allow(view).to receive(:viewer).and_return(viewer)
    stub_template 'metadata/_iiif_drag_and_drop_icon.html.erb' => 'Icon'
    render
  end

  it 'includes a media accessibility note' do
    expect(rendered).to have_css('dt', text: 'Media accessibility', visible: false)
    expect(rendered).to have_css(
      'dd',
      text: /A transcript may be available in the Download panel/,
      visible: false
    )
  end

  it 'links to the feedback address' do
    expect(rendered).to have_css("a[href='mailto:#{Settings.purl_feedback_email}']", text: Settings.purl_feedback_email, visible: false)
  end
end
