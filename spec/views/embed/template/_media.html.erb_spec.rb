require 'rails_helper'

RSpec.describe 'embed/template/_media.html.erb' do
  include PURLFixtures

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:object) { Embed::PURL.new('12345') }
  let(:viewer) { Embed::Viewer::Media.new(request) }
  let(:response) { video_purl }

  before do
    view.lookup_context.view_paths.push 'app/views/embed'
    allow(request).to receive(:purl_object).and_return(object)
    allow(viewer).to receive(:asset_host).and_return('http://example.com/')
    allow(view).to receive(:viewer).and_return(viewer)
    allow(object).to receive(:response).and_return(response)
    render
  end

  it 'implements the MediaTag class appropriately and gets a video tag' do
    expect(rendered).to have_css('video', visible: false)
  end

  describe 'media tag' do
    let(:response) { video_with_spaces_in_filename_purl }

    it 'does not do URL escaping on sources' do
      source = Capybara.string(rendered).all('video source', visible: false).first
      expect(source['src']).not_to include('%20')
      expect(source['src']).not_to include('&amp;')
    end
  end
end
