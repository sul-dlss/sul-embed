require 'rails_helper'

describe Embed::Viewer::WasSeed do
  include PURLFixtures
  include WasSeedThumbsFixtures
  let(:request) { Embed::Request.new(url: 'http://purl.stanford.edu/abc123') }
  let(:was_seed_viewer) { Embed::Viewer::WasSeed.new(request) }
  let(:purl) { "#{Settings.purl_url}/abc123" }

  describe 'initialize' do
    it 'should be an Embed::Viewer::WasSeed' do
      expect(request).to receive(:purl_object).and_return(nil)
      expect(was_seed_viewer).to be_an Embed::Viewer::WasSeed
    end
  end

  describe 'self.supported_types' do
    it 'should return an array of supported types' do
      expect(Embed::Viewer::WasSeed.supported_types).to eq [:'webarchive-seed']
    end
  end

  describe 'body_html' do
    it 'should return Was Seed viewer body' do
      expect(request).to receive(:hide_title?).at_least(:once).and_return(false)

      stub_purl_response_and_request(was_seed_purl, request)
      allow(was_seed_viewer).to receive(:asset_host).at_least(:twice).and_return('http://example.com/')
      allow(was_seed_viewer).to receive(:thumbs_list).and_return(get_thumbs_list_fixtures)

      html = Capybara.string(was_seed_viewer.to_html)
      # visible false because we display:none the container until we've loaded the CSS.
      expect(html).to have_css '.sul-embed-was-seed', visible: false
      expect(html).to have_css '.sul-embed-was-thumb-list', visible: false, count: 1
      expect(html).to have_css '.sul-embed-was-thumb-item', visible: false, count: 4
      expect(html).to have_css '.sul-embed-was-thumb-item-div', visible: false, count: 4
      expect(html).to have_css '.sul-embed-was-thumb-item-div[style="height: 200px; width: 200px;"]', visible: false, count: 4
      expect(html).to have_css '.sul-embed-was-seed[data-sul-thumbs-list-count="4"]', visible: false

      expect(html).to have_css '.sul-embed-was-thumb-item-div a[href="https://swap.stanford.edu/20121129060351/http://naca.central.cranfield.ac.uk/"]', visible: false
      expect(html).to have_css '.sul-embed-was-thumb-item-date', text: '29-Nov-2012', visible: false
      expect(html).to have_css '.sul-embed-was-thumb-item img[src="https://stacks.stanford.edu/image/iiif/gb089bd2251%2F20121129060351/full/200,/0/default.jpg"]', visible: false

      expect(html).to have_css '.sul-embed-was-thumb-item img[style="height: 176px;"]', visible: false

      expect(html).to have_css '.sul-embed-was-thumb-item-div a[href="https://swap.stanford.edu/20130412231301/http://naca.central.cranfield.ac.uk/"]', visible: false
      expect(html).to have_css '.sul-embed-was-thumb-item-date', text: '12-Apr-2013', visible: false
      expect(html).to have_css '.sul-embed-was-thumb-item img[src="https://stacks.stanford.edu/image/iiif/gb089bd2251%2F20130412231301/full/200,/0/default.jpg"]', visible: false
    end
  end

  describe 'thumbs_list' do
    it 'calls the Embed::WasSeedThumbs with the same druid id' do
      stub_request(request)
      allow_any_instance_of(Embed::WasSeedThumbs).to receive(:get_thumbs_list)

      expect(Embed::WasSeedThumbs).to receive(:new).with('12345').and_return(Embed::WasSeedThumbs.new('12345'))
      was_seed_viewer.thumbs_list
    end
    it 'calls the Embed::WasSeedThumbs with the same druid id' do
      stub_request(request)
      allow_any_instance_of(Embed::WasSeedThumbs).to receive(:get_thumbs_list).and_return(get_thumbs_list_fixtures)

      expect(Embed::WasSeedThumbs).to receive(:new).with('12345').and_return(Embed::WasSeedThumbs.new('12345'))
      expect(was_seed_viewer.thumbs_list).to eq(get_thumbs_list_fixtures)
    end
  end

  describe 'format_memento_datetime' do
    it 'returns a formated memento datetime' do
      stub_request(request)
      expect(was_seed_viewer.format_memento_datetime('20121129060351')).to eq('29-Nov-2012')
    end
  end

  describe '.external_url' do
    it 'should build the external url based on wayback url as extracted from prul' do
      stub_purl_response_and_request(was_seed_purl, request)
      expect(was_seed_viewer.external_url).to eq('https://swap.stanford.edu/*/http://naca.central.cranfield.ac.uk/')
    end
  end

  describe '.item_size' do
    it 'returns the item_size based on the default_body_height' do
      expect(was_seed_viewer.item_size).to eq([200, 200])
    end
    it 'returns the item_size based on defined body_height' do
      request_with_max_height = Embed::Request.new(maxheight: 500, url: purl)
      customized_was_seed_viewer = Embed::Viewer::WasSeed.new(request_with_max_height)

      expect(customized_was_seed_viewer.item_size).to eq([347, 347])
    end
  end

  describe '.image_height' do
    it 'returns the image_height based on the item_size' do
      allow(was_seed_viewer).to receive(:item_size).and_return([100, 100])
      expect(was_seed_viewer.image_height).to eq(76)
    end
  end

  def get_thumbs_list_fixtures
    JSON.parse(thumbs_list)['thumbnails']
  end
end
