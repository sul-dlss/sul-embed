require 'rails_helper'

describe EmbedController do
  describe 'GET embed' do
    it 'has a 400 status code without url params' do
      get :get
      expect(response.status).to eq(400)
    end
    it 'has a 400 status when a PURL that is not embeddable is requested' do
      get :get, params: { url: 'http://purl.stanford.edu/tz959sb6952' }
      expect(response.status).to eq(400)
    end
    it 'has a 404 status code without matched url scheme params' do
      get :get, params: { url: 'http://www.example.com' }
      expect(response.status).to eq(404)
    end
    it 'has a 404 status code without a druid in the URL' do
      get :get, params: { url: 'http://purl.stanford.edu/' }
      expect(response.status).to eq(404)
    end
    it 'has a 404 status for a PURL object that does not exists' do
      get :get, params: { url: 'http://purl.stanford.edu/abc123notanobject' }
      expect(response.status).to eq(404)
    end
    it 'has a 415 status code for an invalid format' do
      get :get, params: { url: 'http://purl.stanford.edu/abc123', format: 'yml' }
      expect(response.status).to eq(415)
    end
    it 'has a 200 status code for a matched url scheme param' do
      get :get, params: { url: 'http://purl.stanford.edu/fn662rv4961' }
      expect(response.status).to eq(200)
    end
  end
  describe 'GET iframe' do
    it 'has a 400 status code without url params' do
      get :iframe
      expect(response.status).to eq(400)
    end
    it 'has a 404 status code without matched url scheme params' do
      get :iframe, params: { url: 'http://www.example.com' }
      expect(response.status).to eq(404)
    end
    it 'has a 404 status code without a druid in the URL' do
      get :iframe, params: { url: 'http://purl.stanford.edu/' }
      expect(response.status).to eq(404)
    end
    it 'has a 404 status for a PURL object that does not exists' do
      get :iframe, params: { url: 'http://purl.stanford.edu/abc123notanobject' }
      expect(response.status).to eq(404)
    end
    it 'has a 415 status code for an invalid format' do
      get :iframe, params: { url: 'http://purl.stanford.edu/abc123', format: 'yml' }
      expect(response.status).to eq(415)
    end
    it 'should not have an X-Frame-Options in the headers (so embedding in an iframe is allowed)' do
      get :iframe, params: { url: 'http://purl.stanford.edu/fn662rv4961' }
      expect(response.headers['X-Frame-Options']).to be_nil
    end
    it 'should return HTML' do
      get :iframe, params: { url: 'http://purl.stanford.edu/fn662rv4961' }
      expect(response.status).to eq(200)
    end
  end
end
