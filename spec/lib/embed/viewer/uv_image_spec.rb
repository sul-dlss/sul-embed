require 'rails_helper'

describe Embed::Viewer::UVImage do
  include PURLFixtures
  subject(:uv_image_viewer) { Embed::Viewer::UVImage.new(request) }

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:purl) { "#{Settings.purl_url}/abc123" }

  describe 'initialize' do
    it 'should be an Embed::Viewer::WasSeed' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(uv_image_viewer).to be_an Embed::Viewer::UVImage
    end
  end

  it { is_expected.to have_attributes(header_height: 0, footer_height: 0) }
end
