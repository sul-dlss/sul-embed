# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::PdfComponent, type: :component do
  include PurlFixtures

  let(:url) { 'https://purl.stanford.edu/sq929fn8035' }
  let(:embed_request) { Embed::Request.new(url:) }
  let(:viewer) { Embed::ViewerFactory.new(embed_request).viewer }

  before do
    stub_request(:get, 'https://purl.stanford.edu/sq929fn8035.json')
      .to_return(status: 200, body: pdf_public_json, headers: {})
  end

  it 'renders the full screen button by default' do
    rendered_ng_doc_fragment = render_inline(described_class.new(viewer:))
    expect(rendered_ng_doc_fragment.xpath('.//button[@id="full-screen-button" and @aria-label="Full screen"]').count).to eq(1)
  end

  context 'when the browser is chromium based' do
    let(:companion_windows_component) { Embed::CompanionWindowsComponent.new(viewer:, stimulus_controller: 'file-auth') }

    before do
      allow(Embed::CompanionWindowsComponent).to receive(:new).with(viewer:, stimulus_controller: 'file-auth fullscreen').and_return(companion_windows_component)
      allow(companion_windows_component).to receive(:requested_by_chromium?).and_return(true)
    end

    it 'does not render the full screen button' do
      rendered_ng_doc_fragment = render_inline(described_class.new(viewer:))
      expect(rendered_ng_doc_fragment.xpath('.//button[@id="full-screen-button"]').count).to eq(0)
      expect(rendered_ng_doc_fragment.xpath('.//button[@aria-label="Full screen"]').count).to eq(0)
    end
  end
end
