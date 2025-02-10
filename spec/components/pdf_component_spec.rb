# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PdfComponent, type: :component do
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
    expect(rendered_ng_doc_fragment.xpath('.//button[@aria-label="Full screen"]').count).to eq(1)
  end

  context 'when the browser is chrome' do
    let(:user_agent_string) { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36' }

    before do
      vc_test_request.headers['User-Agent'] = user_agent_string
    end

    it 'does not render the full screen button' do
      rendered_ng_doc_fragment = render_inline(described_class.new(viewer:))
      expect(rendered_ng_doc_fragment.xpath('.//button[@aria-label="Full screen"]').count).to eq(0)
    end
  end

  context 'when the browser is Edge' do
    let(:user_agent_string) { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 Edg/126.0.0.0' }

    before do
      vc_test_request.headers['User-Agent'] = user_agent_string
    end

    it 'does not render the full screen button' do
      rendered_ng_doc_fragment = render_inline(described_class.new(viewer:))
      expect(rendered_ng_doc_fragment.xpath('.//button[@aria-label="Full screen"]').count).to eq(0)
    end
  end
end
