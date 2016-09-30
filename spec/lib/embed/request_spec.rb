require 'rails_helper'

describe Embed::Request do
  let(:purl) { "#{Settings.purl_url}/abc123" }
  describe 'format' do
    it 'should default to json when no format is provided' do
      expect(Embed::Request.new(url: purl).format).to eq 'json'
    end
    it 'should honor format parameters sent in through the URL' do
      expect(Embed::Request.new(url: purl, format: 'xml').format).to eq 'xml'
    end
  end

  describe 'sizes' do
    context 'when potentially harmful strings are passed' do
      let(:request) do
        Embed::Request.new(
          url: purl,
          maxheight: '<script>alert("YouGotPwned!")</script>',
          maxwidth: '<script>alert("YouGotPwnedAgain!")</script>'
        )
      end

      it 'are nil' do
        expect(request.maxheight).to be_nil
        expect(request.maxwidth).to be_nil
      end
    end

    context 'when a numbers are passed as strings' do
      let(:request) { Embed::Request.new(url: purl, maxheight: '500', maxwidth: '300') }

      it 'are cast to integers' do
        expect(request.maxheight).to eq 500
        expect(request.maxwidth).to eq 300
      end
    end
  end

  describe 'hide_title?' do
    it 'should return false by default' do
      expect(Embed::Request.new(url: purl).hide_title?).to be_falsy
    end
    it 'should return true if the incoming request asked to hide the title' do
      expect(Embed::Request.new(url: purl, hide_title: 'true').hide_title?).to be_truthy
    end
  end

  describe 'min_files_to_search' do
    it 'returns the value passed in via the request parameters' do
      expect(Embed::Request.new(url: purl, min_files_to_search: '5').min_files_to_search).to eq '5'
    end
  end

  describe 'hide_search?' do
    it 'defaults to false' do
      expect(Embed::Request.new(url: purl).hide_search?).to be_falsy
    end

    it 'is true when the incoming request asked to hide the search box' do
      expect(Embed::Request.new(url: purl, hide_search: 'true').hide_search?).to be_truthy
    end
  end

  describe 'fullheight?' do
    it 'default to false' do
      expect(Embed::Request.new(url: purl)).not_to be_fullheight
    end

    it 'is true when the incoming request asks to use fullheight mode' do
      expect(Embed::Request.new(url: purl, fullheight: 'true')).to be_fullheight
    end
  end

  describe 'as_url_params' do
    let(:url_params) do
      Embed::Request.new(url: purl, hide_title: 'true', arbitrary_param: 'something').as_url_params
    end

    it 'is a hash of parameters to be turned into url optinos' do
      expect(url_params).to be_a Hash
      expect(url_params[:hide_title]).to eq('true')
    end

    it 'does not include arbitrary params sent in' do
      expect(url_params).not_to have_key(:arbitrary_param)
    end
  end

  describe 'object_druid' do
    it 'should parse the druid out of the incoming URL parameter' do
      expect(Embed::Request.new(url: purl).object_druid).to eq 'abc123'
    end
  end
  describe 'rails_request' do
    let(:rails_request) { double('rails-request') }
    it 'should include the rails request (for generating asset URLs in viewer HTML)' do
      expect(Embed::Request.new({ url: purl }, rails_request).rails_request).to eq rails_request
    end
  end
  describe 'purl_object' do
    let(:object) { double('purl') }
    it 'should instantiate a PURL object w/ the object druid' do
      expect(Embed::PURL).to receive(:new).with('abc123').and_return(object)
      expect(Embed::Request.new(url: purl).purl_object).to be object
    end
  end
  describe 'error handling' do
    it 'should raise an error when no URL is provided' do
      expect(-> { Embed::Request.new({}) }).to raise_error(Embed::Request::NoURLProvided)
    end
    it 'should raise an error when a URL is provided that does not match the scheme' do
      expect(-> { Embed::Request.new(url: 'http://library.stanford.edu') }).to raise_error(Embed::Request::InvalidURLScheme)
    end
    it 'should raise an error when the scheme matches but there is no valid ID in the URL' do
      expect(-> { Embed::Request.new(url: 'http://purl.stanford.edu/') }).to raise_error(Embed::Request::InvalidURLScheme)
    end
    it 'should raise an error when an invalid format is requested' do
      expect(-> { Embed::Request.new(url: 'http://purl.stanford.edu/abc', format: 'yml') }).to raise_error(Embed::Request::InvalidFormat)
    end
  end
end
