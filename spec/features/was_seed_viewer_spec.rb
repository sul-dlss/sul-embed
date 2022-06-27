# frozen_string_literal: true

require 'rails_helper'

describe 'was seed viewer public', js: true do
  include PurlFixtures
  include WasTimeMapFixtures

  let(:fake_connection) do
    instance_double(Faraday::Connection, get: double('response', body: timemap, success?: true))
  end

  before do
    allow_any_instance_of(Embed::WasTimeMap).to receive(:redirectable_connection).and_return(fake_connection)
    expect(fake_connection).to receive(:get).once
    stub_purl_response_with_fixture(was_seed_purl)
    visit_iframe_response
  end

  context 'with current timemap behavior' do
    describe 'loading was-seed-viewer' do
      it 'displays the viewer on the frame' do
        expect(page).to have_css('.sul-embed-was-seed', count: 1)
        expect(page).to have_css('.sul-embed-was-seed-list-item', count: 7, visible: :all)
      end

      it 'links to the memento URI with a _parent target' do
        expect(page).to have_css('.sul-embed-was-seed-list-item a.sul-embed-stretched-link[href="https://swap.stanford.edu/20090718213431/http://ennejah.info/"]', text: '2009-07-18 21:34:31 UTC')
      end

      it 'has the thumbnail' do
        expect(page).to have_css('img[src="https://stacks.stanford.edu/image/iiif/ignored%2Fthumbnail/full/200,/0/default.jpg"]', visible: :all)
      end
    end
  end

  context 'with new timemap behavior' do
    it 'links to the memento URI with a _parent target' do
      expect(page).to have_css('.sul-embed-was-seed-list-item a.sul-embed-stretched-link[href="https://swap.stanford.edu/20090718213431/http://ennejah.info/"]', text: '2009-07-18 21:34:31 UTC')
    end

    it 'has the thumbnail' do
      expect(page).to have_css('img[src="https://stacks.stanford.edu/image/iiif/ignored%2Fthumbnail/full/200,/0/default.jpg"]', visible: :all)
    end

    describe 'loading was-seed-viewer' do
      it 'displays the viewer on the frame' do
        expect(page).to have_css('.sul-embed-was-seed', count: 1)
        expect(page).to have_css('.sul-embed-was-seed-list-item', count: 7, visible: :all)
      end

      it 'links to the memento URI with a _parent target' do
        expect(page).to have_css('.sul-embed-was-seed-list-item a.sul-embed-stretched-link[href="https://swap.stanford.edu/20090718213431/http://ennejah.info/"]', text: '2009-07-18 21:34:31 UTC')
      end

      it 'has the thumbnail' do
        expect(page).to have_css('img[src="https://stacks.stanford.edu/image/iiif/ignored%2Fthumbnail/full/200,/0/default.jpg"]', visible: :all)
      end
    end
  end
end
