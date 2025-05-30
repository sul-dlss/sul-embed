# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Request do
  let(:purl) { "#{Settings.purl_url}/abc123" }

  describe 'format' do
    it 'defaults to json when no format is provided' do
      expect(described_class.new(url: purl).format).to eq 'json'
    end

    it 'honors format parameters sent in through the URL' do
      expect(described_class.new(url: purl, format: 'xml').format).to eq 'xml'
    end
  end

  describe 'sizes' do
    context 'when potentially harmful strings are passed' do
      let(:request) do
        described_class.new(
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

    context 'when a numbers are passed without units' do
      let(:request) { described_class.new(url: purl, maxheight: '500', maxwidth: '300') }

      it 'converts to px units' do
        expect(request.maxheight).to eq '500px'
        expect(request.maxwidth).to eq '300px'
      end
    end

    context 'when a numbers are passed with units' do
      let(:request) { described_class.new(url: purl, maxheight: '50vh', maxwidth: '100vw') }

      it 'preserves the provided units' do
        expect(request.maxheight).to eq '50vh'
        expect(request.maxwidth).to eq '100vw'
      end
    end
  end

  describe 'hide_title?' do
    it 'returns false by default' do
      expect(described_class.new(url: purl)).not_to be_hide_title
    end

    it 'returns true if the incoming request asked to hide the title' do
      expect(described_class.new(url: purl, hide_title: 'true')).to be_hide_title
    end
  end

  describe 'min_files_to_search' do
    it 'returns the value passed in via the request parameters' do
      expect(described_class.new(url: purl, min_files_to_search: '5').min_files_to_search).to eq '5'
    end
  end

  describe 'hide_search?' do
    it 'defaults to false' do
      expect(described_class.new(url: purl)).not_to be_hide_search
    end

    it 'is true when the incoming request asked to hide the search box' do
      expect(described_class.new(url: purl, hide_search: 'true')).to be_hide_search
    end
  end

  describe 'enable_comparison?' do
    it 'defaults to false' do
      expect(described_class.new(url: purl)).not_to be_enable_comparison
    end

    it 'is true when the incoming request asks to enable_comparison' do
      expect(described_class.new(url: purl, enable_comparison: 'true')).to be_enable_comparison
    end
  end

  describe 'as_url_params' do
    let(:url_params) do
      described_class.new(url: purl, hide_title: 'true', arbitrary_param: 'something').as_url_params
    end

    it 'is a hash of parameters to be turned into url optinos' do
      expect(url_params).to be_a Hash
      expect(url_params[:hide_title]).to eq('true')
    end

    it 'does not include arbitrary params sent in' do
      expect(url_params).not_to have_key(:arbitrary_param)
    end
  end

  describe 'canvas_index' do
    it 'passes through the canvas_index param' do
      expect(described_class.new(url: purl, canvas_index: 3).canvas_index).to eq 3
    end

    it 'defaults to nil' do
      expect(described_class.new(url: purl).canvas_index).to be_nil
    end
  end

  describe 'object_druid' do
    it 'parses the druid out of the incoming URL parameter' do
      expect(described_class.new(url: purl).object_druid).to eq 'abc123'
    end
  end

  describe 'purl_object' do
    let(:object) { instance_double(Embed::Purl) }

    it 'instantiates a Purl object w/ the object druid' do
      expect(Embed::Purl).to receive(:find).with('abc123', nil).and_return(object)
      expect(described_class.new(url: purl).purl_object).to be object
    end

    context 'when url is a versioned purl' do
      let(:purl) { "#{Settings.purl_url}/abc123/version/1" }

      it 'instantiates a Purl object w/ the object druid and version ID' do
        expect(Embed::Purl).to receive(:find).with('abc123', '1').and_return(object)
        expect(described_class.new(url: purl).purl_object).to be object
      end
    end
  end

  describe 'error handling' do
    it 'raises an error when no URL is provided' do
      expect { described_class.new({}).validate! }.to raise_error(Embed::Request::NoURLProvided)
    end

    it 'raises an error when a URL is provided that does not match the scheme' do
      expect { described_class.new(url: 'http://library.stanford.edu').validate! }.to raise_error(Embed::Request::InvalidURLScheme)
    end

    it 'raises an error when the scheme matches but there is no valid ID in the URL' do
      expect { described_class.new(url: 'http://purl.stanford.edu/').validate! }.to raise_error(Embed::Request::InvalidURLScheme)
    end

    it 'raises an error when an invalid format is requested' do
      expect { described_class.new(url: 'http://purl.stanford.edu/abc', format: 'yml').validate! }.to raise_error(Embed::Request::InvalidFormat)
    end
  end
end
