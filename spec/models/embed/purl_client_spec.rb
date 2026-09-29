# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::PurlClient do
  subject(:client) { described_class.new(url:) }

  let(:url) { 'https://purl.stanford.edu/12345.json' }

  describe '#response' do
    it 'returns and memoizes a successful response' do
      request = stub_request(:get, url).to_return(status: 200, body: '{}')

      expect(client.response.body).to eq '{}'
      expect(client.response.body).to eq '{}'
      expect(request).to have_been_requested.once
    end

    it 'uses the configured timeouts' do
      connection = instance_double(Faraday::Connection)
      request_options = Faraday::RequestOptions.new
      request = instance_double(Faraday::Request, options: request_options)
      response = instance_double(Faraday::Response, success?: true)
      allow(Faraday).to receive(:new).with(url:).and_return(connection)
      allow(connection).to receive(:get).and_yield(request).and_return(response)

      client.response

      expect(request_options.timeout).to eq Settings.purl_read_timeout
      expect(request_options.open_timeout).to eq Settings.purl_conn_timeout
    end

    it 'raises a resource error that identifies an unsuccessful request' do
      stub_request(:get, url).to_return(status: 404)

      expect { client.response }
        .to raise_error(Embed::Purl::ResourceNotAvailable, "Resource unavailable #{url} (status: 404)")
    end

    it 'raises a resource error that identifies a connection failure' do
      stub_request(:get, url).to_timeout

      expect { client.response }
        .to raise_error(Embed::Purl::ResourceNotAvailable, "Resource unavailable #{url} (connection error)")
    end
  end
end
