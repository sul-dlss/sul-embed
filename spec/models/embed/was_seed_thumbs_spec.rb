require 'rails_helper'

describe Embed::WasSeedThumbs do
  include WasSeedThumbsFixtures
  describe 'initialize' do
    it 'initializes the WasSeedThumbs with the druid' do
      seed_thumbs = Embed::WasSeedThumbs.new('ab123cd4567')
      expect(seed_thumbs.druid).to eq('ab123cd4567')
    end
  end

  describe 'get_thumbs_list' do
    it 'returns a list of thumbs' do
      allow_any_instance_of(Embed::WasSeedThumbs).to receive(:response).and_return(thumbs_list)

      seed_thumbs = Embed::WasSeedThumbs.new('ab123cd4567')
      thumbs_list = seed_thumbs.get_thumbs_list
      expect(thumbs_list.length).to eq(2)
      expect(thumbs_list[0]).to eq({
        'memento_uri' => 'https://swap.stanford.edu/20121129060351/http://naca.central.cranfield.ac.uk/',
        'memento_datetime' => '20121129060351',
        'thumbnail_uri' => 'https://stacks.stanford.edu/image/iiif/gb089bd2251%2F20121129060351/full/200,/0/default.jpg'
      })
      expect(thumbs_list[1]).to eq({
        'memento_uri' => 'https://swap.stanford.edu/20130412231301/http://naca.central.cranfield.ac.uk/',
        'memento_datetime' => '20130412231301',
        'thumbnail_uri' => 'https://stacks.stanford.edu/image/iiif/gb089bd2251%2F20130412231301/full/200,/0/default.jpg'
      })
    end
    it 'returns an emtpy list for seed uris without thumbs' do
      allow_any_instance_of(Embed::WasSeedThumbs).to receive(:response).and_return(empty_thumbs_list)
      seed_thumbs = Embed::WasSeedThumbs.new('ab123cd4567')
      thumbs_list = seed_thumbs.get_thumbs_list
      expect(thumbs_list).to eq([])
    end
    it 'raises an error response with nil where there is a problem in retrieving the list' do
      allow_any_instance_of(Embed::WasSeedThumbs).to receive(:response).and_return(nil)
      seed_thumbs = Embed::WasSeedThumbs.new('ab123cd4567')
      expect{seed_thumbs.get_thumbs_list}.to raise_error(Embed::WasSeedThumbs::ResourceNotAvailable)
    end
  end
  
  describe 'response' do
    pending
  end

  describe 'was_thumbs_url' do
    it 'builds the was_thumbs url based on the configuratino and druid' do
      seed_thumbs = Embed::WasSeedThumbs.new('ab123cd4567')
      Settings.was_thumbs_url = 'https://thumbnail-service-example'
      expect(seed_thumbs.was_thumbs_url).to eq('https://thumbnail-service-example/ab123cd4567')
    end
  end
end
