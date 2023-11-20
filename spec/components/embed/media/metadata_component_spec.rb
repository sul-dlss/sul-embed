# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Media::MetadataComponent, type: :component do
  include PurlFixtures

  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:object) { Embed::Purl.find('12345') }
  let(:viewer) { Embed::Viewer::Media.new(request) }

  before do
    allow(request).to receive(:purl_object).and_return(object)
    allow(object).to receive(:response).and_return(video_purl)
    render_inline(described_class.new(viewer:))
  end

  it 'includes a media accessibility note' do
    expect(page).to have_css('dt', text: 'Media accessibility', visible: :all)
    expect(page).to have_css(
      'dd',
      text: /A transcript may be available in the Download panel/,
      visible: :all
    )
  end

  it 'links to the feedback address' do
    expect(page).to have_css("a[href='mailto:#{Settings.purl_feedback_email}']", text: Settings.purl_feedback_email, visible: :all)
  end
end
