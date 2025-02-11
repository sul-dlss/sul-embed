# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Embed requests' do
  let(:purl) do
    build(:purl, :file, title: 'File Title',
                        contents: [build(:resource, files: [build(:resource_file, :document, label: 'File1 Label')])])
  end

  before do
    allow(Embed::Purl).to receive(:find).and_return(purl)
  end

  describe 'GET embed' do
    context 'without url params' do
      it 'has a 400 status code' do
        get '/embed'
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when a Purl that is not embeddable is requested' do
      let(:purl) do
        build(:purl, contents: [])
      end

      it 'has a 400 status' do
        get '/embed', params: { url: 'http://purl.stanford.edu/tz959sb6952' }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'without matched url scheme params' do
      it 'has a 404 status code' do
        get '/embed', params: { url: 'http://www.example.com' }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'without a druid in the URL' do
      it 'has a 404 status code' do
        get '/embed', params: { url: 'http://purl.stanford.edu/' }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when requesting a Purl object that does not exists' do
      before do
        allow(Embed::Purl).to receive(:find).and_raise(Embed::Purl::ResourceNotAvailable)
      end

      it 'has a 404 status' do
        get '/embed', params: { url: 'http://purl.stanford.edu/abc123notanobject' }
        expect(response).to have_http_status(:not_found)
      end
    end

    it 'has a 415 status code for an invalid format' do
      get '/embed', params: { url: 'http://purl.stanford.edu/abc123', format: 'yml' }
      expect(response).to have_http_status(:unsupported_media_type)
    end

    context 'with a valid request (json)' do
      it 'has a 200 status code for a matched url scheme param' do
        get '/embed', params: { url: 'http://purl.stanford.edu/fn662rv4961' }
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to include({ 'title' => 'File Title',
                                                  'type' => 'rich', 'version' => '1.0',
                                                  'provider_name' => 'SUL Embed Service' })
        expect(response.headers.keys).to include('etag', 'last-modified')
      end

      it 'has a 200 status code and html returns correct parameters' do
        get '/embed', params: { url: 'http://purl.stanford.edu/fn662rv4961', new_viewer: true, hide_title: false, invalid_field: true }
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['html']).to include('new_viewer=true')
        expect(response.parsed_body['html']).to include('hide_title=false')
        expect(response.parsed_body['html']).not_to include('invalid_field=true')
      end
    end

    context 'with a valid request (xml)' do
      it 'has a 200 status code for a matched url scheme param' do
        get '/embed.xml', params: { url: 'http://purl.stanford.edu/fn662rv4961' }
        expect(response).to have_http_status(:ok)
        xml = Hash.from_xml(response.parsed_body)
        expect(xml.fetch('oembed')).to include({ 'title' => 'File Title',
                                                 'type' => 'rich', 'version' => '1.0',
                                                 'provider_name' => 'SUL Embed Service' })
      end
    end
  end

  describe 'GET iframe' do
    it 'has a 400 status code without url params' do
      get '/iframe'
      expect(response).to have_http_status(:bad_request)
    end

    it 'has a 404 status code without matched url scheme params' do
      get '/iframe', params: { url: 'http://www.example.com' }
      expect(response).to have_http_status(:not_found)
    end

    it 'has a 404 status code without a druid in the URL' do
      get '/iframe', params: { url: 'http://purl.stanford.edu/' }
      expect(response).to have_http_status(:not_found)
    end

    context 'when requesting a Purl object that does not exists' do
      before do
        allow(Embed::Purl).to receive(:find).and_raise(Embed::Purl::ResourceNotAvailable)
      end

      it 'has a 404 status' do
        get '/iframe', params: { url: 'http://purl.stanford.edu/abc123notanobject' }
        expect(response).to have_http_status(:not_found)
      end
    end

    it 'has a 415 status code for an invalid format' do
      get '/iframe', params: { url: 'http://purl.stanford.edu/abc123', format: 'yml' }
      expect(response).to have_http_status(:unsupported_media_type)
    end

    context 'when the object exists' do
      it 'does not have an X-Frame-Options in the headers (so embedding in an iframe is allowed)' do
        get '/iframe', params: { url: 'http://purl.stanford.edu/fn662rv4961' }
        expect(response).to have_http_status(:ok)
        expect(response.headers['X-Frame-Options']).to be_nil
        expect(response.headers.keys).to include('etag', 'last-modified')
      end
    end
  end
end
