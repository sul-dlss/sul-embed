# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Purl::Resource do
  include PurlFixtures
  it 'gets the type attribute' do
    stub_purl_response_with_fixture(file_purl)
    expect(Embed::Purl.new('12345').contents.first.type).to eq 'file'
  end

  it 'gets the description from the label element' do
    stub_purl_response_with_fixture(file_purl)
    expect(Embed::Purl.new('12345').contents.first.description).to eq 'File1 Label'
  end

  it 'gets the description from the attr[name="label"] element' do
    stub_purl_response_with_fixture(multi_file_purl)
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
      stub_purl_response_with_fixture(file_purl)
      expect(Embed::Purl.new('12345').contents.first.files.all?(Embed::Purl::ResourceFile)).to be true
    end
  end

  describe '#vtt' do
    let(:resource) { Embed::Purl.new('12345').contents.first }

    context 'when it has a vtt transcript' do
      subject { resource.vtt[0].title }

      before { stub_purl_response_with_fixture(video_purl_with_vtt) }

      it { is_expected.to eq 'abc_123_cap.webvtt' }
    end

    context 'when it does not have a vtt transcript' do
      subject { resource.vtt[0] }

      before { stub_purl_response_with_fixture(single_video_purl) }

      it { is_expected.to be_nil }
    end
  end
end
