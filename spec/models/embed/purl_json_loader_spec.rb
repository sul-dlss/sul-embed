# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::PurlJsonLoader do
  include PurlFixtures

  subject(:data) { described_class.load('12345') }

  context 'when the response from Purl returns successfully' do
    before do
      stub_request(:get, 'https://purl.stanford.edu/12345.json')
        .to_return(status: 200, body: xml, headers: {})
    end

    context 'with a public purl with file type' do
      let(:xml) { file_purl_json }

      it { is_expected.to include({ title: 'File Title', type: 'file', embargoed: false, public: true }) }

      it 'has contents' do
        expect(data[:contents]).to all(be_a(Embed::Purl::Resource))
      end
    end

    context 'with a stanford only purl with file type' do
      let(:xml) { stanford_restricted_file_purl_json }

      it { is_expected.to include({ type: 'file', embargoed: false, public: false, stanford_only_unrestricted: true, citation_only: false }) }
    end

    context 'with an embargoed purl with file type' do
      let(:xml) { embargoed_file_purl_json }

      it { is_expected.to include({ embargoed: true, embargo_release_date: '2053-12-21', public: false }) }
    end

    context 'with a was seed' do
      let(:xml) { was_seed_purl_json }

      it 'finds the data' do
        expect(data).to include({ archived_site_url: 'https://swap.stanford.edu/*/http://naca.central.cranfield.ac.uk/',
                                  type: 'webarchive-seed', collections: ['mk656nf8485'] })
      end
    end

    context 'with an envelope' do
      let(:xml) { geo_purl_public_json }

      it 'creates a bounding_box' do
        expect(data).to include({ bounding_box: [['-1.478794', '29.572742'], ['4.234077', '35.000308']] })
      end
    end

    describe 'license' do
      context 'with a creative commons license' do
        let(:xml) { file_purl_json }

        it { is_expected.to include({ license: 'This work has been identified as being free of known restrictions under copyright law, including all related and neighboring rights (Public Domain Mark 1.0).' }) }
      end

      context 'with an odc license' do
        let(:xml) { odc_license_json }

        it { is_expected.to include({ license: 'This work is licensed under an Open Data Commons Attribution License v1.0.' }) }
      end

      context 'with no license' do
        let(:xml) { embargoed_file_purl_json }

        it { is_expected.to include({ license: nil }) }
      end
    end

    describe '#collections' do
      context 'when collections are present' do
        let(:xml) { was_seed_purl_json }

        it 'formats a list of collection druids' do
          expect(data).to include({ collections: ['mk656nf8485'] })
        end
      end

      context 'when collections are not present' do
        let(:xml) { file_purl_json }

        it 'formats a list of collection druids' do
          expect(data).to include({ collections: [] })
        end
      end
    end
  end

  context 'when the response from Purl is not successfull' do
    before do
      stub_request(:get, 'https://purl.stanford.edu/12345.json')
        .to_return(status: 404, body: '', headers: {})
    end

    it 'raises an error' do
      expect { data }.to raise_error Embed::Purl::ResourceNotAvailable
    end
  end
end