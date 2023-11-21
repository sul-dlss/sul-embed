# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::PurlXmlLoader do
  include PurlFixtures

  subject(:data) { described_class.load('12345') }

  describe 'load' do
    before { stub_purl_xml_response_with_fixture(xml) }

    context 'with a public file' do
      let(:xml) { file_purl_xml }

      it { is_expected.to include({ title: 'File Title', type: 'file', embargoed: false, public: true }) }
    end

    context 'with an embargoed file' do
      let(:xml) { embargoed_file_purl_xml }

      it { is_expected.to include({ embargoed: true, embargo_release_date: '2053-12-21', public: false }) }
    end
  end
end
