# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::PurlJsonLoader do
  include PurlFixtures

  describe '#purl_json_url' do
    context 'when version id is not supplied' do
      subject(:loader) { described_class.new('12345').send(:purl_json_url) }

      it { is_expected.to eq('https://purl.stanford.edu/12345.json') }
    end

    context 'when version id is supplied' do
      subject(:loader) { described_class.new('12345', '3').send(:purl_json_url) }

      it { is_expected.to eq('https://purl.stanford.edu/12345/version/3.json') }
    end
  end

  describe '#load' do
    subject(:data) { described_class.new('12345').load }

    context 'when the response from Purl returns successfully' do
      before do
        stub_request(:get, 'https://purl.stanford.edu/12345.json')
          .to_return(status: 200, body: json, headers: {})
      end

      context 'with a public purl with file type' do
        let(:json) { file_purl_json }

        it { is_expected.to include({ title: 'File Title', type: 'file', embargoed: false, public: true }) }

        it 'has contents' do
          expect(data[:contents]).to all(be_a(Embed::Purl::Resource))
        end
      end

      context 'with a public purl with collection type' do
        let(:json) { collection_purl_json }

        it { is_expected.to include({ title: 'captioned media', type: 'collection', embargoed: false, public: false }) }

        it 'has empty contents' do
          expect(data[:contents]).to all(be_a(Embed::Purl::Resource))
        end
      end

      context 'with a stanford only purl with file type' do
        let(:json) { stanford_restricted_file_purl_json }

        it { is_expected.to include({ type: 'file', embargoed: false, public: false, stanford_only_unrestricted: true }) }
      end

      context 'with an embargoed purl with file type' do
        let(:json) { embargoed_file_purl_json }

        it { is_expected.to include({ embargoed: true, embargo_release_date: '2053-12-21', public: false }) }
      end

      context 'with a was seed' do
        let(:json) { was_seed_purl_json }

        it 'finds the data' do
          expect(data).to include({ archived_site_url: 'https://swap.stanford.edu/*/http://naca.central.cranfield.ac.uk/',
                                    type: 'webarchive-seed', collections: ['mk656nf8485'] })
        end
      end

      context 'with an envelope' do
        let(:json) { geo_purl_public_json }

        it 'creates a bounding_box' do
          expect(data).to include({ bounding_box: [['-1.478794', '29.572742'], ['4.234077', '35.000308']] })
        end
      end

      context 'with a virtual object' do
        let(:json) { virtual_object_purl_json }
        let(:associate) { Embed::Purl.new }

        before do
          allow(Embed::Purl).to receive(:find).with('kq126jw7402').and_return(associate)
        end

        it 'has contents' do
          expect(data[:contents].first.druid).to eq 'kq126jw7402'
        end
      end

      describe 'license' do
        context 'with a creative commons license' do
          let(:json) { file_purl_json }

          it { is_expected.to include({ license: 'This work has been identified as being free of known restrictions under copyright law, including all related and neighboring rights (Public Domain Mark 1.0).' }) }
        end

        context 'with an odc license' do
          let(:json) { odc_license_json }

          it { is_expected.to include({ license: 'This work is licensed under an Open Data Commons Attribution License v1.0.' }) }
        end

        context 'with no license' do
          let(:json) { embargoed_file_purl_json }

          it { is_expected.to include({ license: nil }) }
        end
      end

      describe '#collections' do
        context 'when collections are present' do
          let(:json) { was_seed_purl_json }

          it 'formats a list of collection druids' do
            expect(data).to include({ collections: ['mk656nf8485'] })
          end
        end

        context 'when collections are not present' do
          let(:json) { file_purl_json }

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

    context 'when the response from Purl times out' do
      before do
        stub_request(:get, 'https://purl.stanford.edu/12345.json').to_timeout
      end

      it 'raises an error' do
        expect { data }.to raise_error Embed::Purl::ResourceNotAvailable
      end
    end
  end

  describe '#etag' do
    subject(:etag) { described_class.new('12345').etag }

    let(:purl_etag) { "W/\"#{Time.zone.now.to_f}\"" }

    before do
      stub_request(:get, 'https://purl.stanford.edu/12345.json')
        .to_return(status: 200, body: file_purl_json, headers: {
                     'ETag' => purl_etag
                   })
    end

    it { is_expected.to eq purl_etag }
  end

  describe '#last_modified' do
    subject(:last_modified) { described_class.new('12345').last_modified }

    let(:purl_last_modified) { Time.zone.now.rfc2822 }

    before do
      stub_request(:get, 'https://purl.stanford.edu/12345.json')
        .to_return(status: 200, body: file_purl_json, headers: {
                     'Last-Modified' => purl_last_modified
                   })
    end

    it { is_expected.to eq purl_last_modified }
  end
end
