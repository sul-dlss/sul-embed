# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Purl::Resource do
  include PurlFixtures
  it 'gets the type attribute' do
    stub_request(:get, 'https://purl.stanford.edu/12345.xml')
      .to_return(status: 200, body: file_purl)
    expect(Embed::Purl.new('12345').contents.first.type).to eq 'file'
  end

  it 'gets the description from the label element' do
    stub_request(:get, 'https://purl.stanford.edu/12345.xml')
      .to_return(status: 200, body: file_purl)
    expect(Embed::Purl.new('12345').contents.first.description).to eq 'File1 Label'
  end

  it 'gets the description from the attr[name="label"] element' do
    stub_request(:get, 'https://purl.stanford.edu/12345.xml')
      .to_return(status: 200, body: multi_file_purl)
    expect(Embed::Purl.new('12345').contents.first.description).to eq 'File1 Label'
  end

  describe '#object_thumbnail?' do
    subject { described_class.new('bc123df4567', node, instance_double(Dor::RightsAuth)) }

    let(:node) { instance_double(Nokogiri::XML::Node, attributes:) }

    context 'when type="thumb"' do
      let(:attributes) { { 'type' => double(value: 'thumb') } }

      it { is_expected.to be_object_thumbnail }
    end

    context 'when thumb="yes"' do
      let(:attributes) { { 'thumb' => double(value: 'yes') } }

      it { is_expected.to be_object_thumbnail }
    end

    context 'when any other value' do
      let(:attributes) { { 'type' => double(value: 'image') } }

      it { is_expected.not_to be_object_thumbnail }
    end
  end

  describe 'files' do
    it 'returns an array of Purl::Resource::ResourceFile objects' do
      stub_request(:get, 'https://purl.stanford.edu/12345.xml')
        .to_return(status: 200, body: file_purl)
      expect(Embed::Purl.new('12345').contents.first.files.all?(Embed::Purl::ResourceFile)).to be true
    end
  end

  describe '#vtt' do
    let(:resource) { Embed::Purl.new('12345').contents.first }

    context 'when it has a vtt transcript' do
      subject { resource.vtt.title }

      before do
        stub_request(:get, 'https://purl.stanford.edu/12345.xml')
          .to_return(status: 200, body: video_purl_with_vtt)
      end

      it { is_expected.to eq 'abc_123_cap.webvtt' }
    end

    context 'when it does not have a vtt transcript' do
      subject { resource.vtt }

      before do
        stub_request(:get, 'https://purl.stanford.edu/12345.xml')
          .to_return(status: 200, body: single_video_purl)
      end

      it { is_expected.to be_nil }
    end
  end
end
