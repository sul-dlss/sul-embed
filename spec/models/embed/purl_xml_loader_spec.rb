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

    context 'with a was seed' do
      let(:xml) { was_seed_purl }

      it 'finds the data' do
        expect(data).to include({ archived_site_url: 'https://swap.stanford.edu/*/http://naca.central.cranfield.ac.uk/',
                                  external_url: 'https://swap.stanford.edu/*/http://naca.central.cranfield.ac.uk/',
                                  type: 'webarchive-seed', collections: ['mk656nf8485'] })
      end
    end

    context 'with an envelope' do
      let(:xml) { geo_purl_public }

      it 'creates a bounding_box' do
        expect(data).to include({ bounding_box: [['-1.478794', '29.572742'], ['4.234077', '35.000308']] })
      end
    end
  end
end
