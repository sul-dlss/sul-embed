# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::Purl::ResourceFile do
  include PurlFixtures
  describe 'attributes' do
    before { stub_purl_xml_response_with_fixture(file_purl_xml) }

    let(:resource_file) { Embed::Purl.new('12345').contents.first.files.first }

    it 'gets the title from from the id attribute' do
      expect(resource_file.title).to eq 'Title of the PDF.pdf'
    end

    it 'gets the hierarchical_title from from the id attribute' do
      expect(resource_file.hierarchical_title).to eq 'Title of the PDF.pdf'
    end

    it 'gets the mimetype from the mimetype attribute' do
      expect(resource_file.mimetype).to eq 'application/pdf'
    end

    it 'gets the size from the size attribute' do
      expect(resource_file.size).to eq 12_345
    end
  end

  describe '#file_url' do
    let(:file_node) do
      Nokogiri::XML(<<~XML
        <file size="12345" mimetype="image/jp2" id="#{file_name}"/>
      XML
                   ).root
    end

    let(:file_name) { 'cool_file' }

    let(:resource) { instance_double(Embed::Purl::Resource, druid: 'abc123') }
    let(:resource_file) { described_class.new('abc123', 'desc', file_node, nil) }

    it 'creates a stacks file url' do
      expect(resource_file.file_url).to eq 'https://stacks.stanford.edu/file/druid:abc123/cool_file'
    end

    it 'adds a download param' do
      expect(resource_file.file_url(download: true)).to eq 'https://stacks.stanford.edu/file/druid:abc123/cool_file?download=true'
    end

    context 'when there are special characters in the file name' do
      let(:file_name) { '[Dissertation] micro-TEC vfinal (for submission)-augmented.pdf' }

      it 'escapes them' do
        expect(resource_file.file_url).to eq 'https://stacks.stanford.edu/file/druid:abc123/%5BDissertation%5D%20micro-TEC%20vfinal%20%28for%20submission%29-augmented.pdf'
      end
    end

    context 'when there are literal slashes in the file name' do
      let(:file_name) { 'path/to/[Dissertation] micro-TEC vfinal (for submission)-augmented.pdf' }

      it 'allows them' do
        expect(resource_file.file_url)
          .to eq 'https://stacks.stanford.edu/file/druid:abc123/path/to/%5BDissertation%5D%20micro-TEC%20vfinal%20%28for%20submission%29-augmented.pdf'
      end
    end
  end

  describe '#hierarchical_title' do
    before { stub_purl_xml_response_with_fixture(hierarchical_file_purl_xml) }

    let(:resource_file) { Embed::Purl.new('12345').hierarchical_contents.dirs.first.dirs.first.files.first }

    it 'get the hierarchical title from the id attribute' do
      expect(resource_file.hierarchical_title).to eq 'Title_of_2_PDF.pdf'
    end
  end

  describe '#label' do
    let(:resource_file) { instance_double(Nokogiri::XML::Element, attributes: { 'id' => double(value: 'The File ID') }) }

    it 'is the resource description' do
      file = described_class.new('abc123', 'The Resource Description', resource_file, double('rights'))
      expect(file.label).to eq 'The Resource Description'
    end
  end

  describe 'previewable?' do
    it 'returns true if the mimetype of the file is previewable' do
      stub_purl_xml_response_with_fixture(image_purl_xml)
      expect(Embed::Purl.new('12345').contents.first.files.first).to be_previewable
    end

    it 'returns false if the mimetype of the file is not previewable' do
      stub_purl_xml_response_with_fixture(file_purl_xml)
      expect(Embed::Purl.new('12345').contents.first.files.first).not_to be_previewable
    end
  end

  describe 'image?' do
    it 'returns true if the mimetype of the file is an image' do
      stub_purl_xml_response_with_fixture(image_purl_xml)
      expect(Embed::Purl.new('12345').contents.first.files.first).to be_image
    end

    it 'returns false if the mimetype of the file is not an image' do
      stub_purl_xml_response_with_fixture(file_purl_xml)
      expect(Embed::Purl.new('12345').contents.first.files.first).not_to be_image
    end
  end

  describe 'rights' do
    describe 'stanford_only?' do
      it 'identifies stanford_only objects' do
        stub_purl_xml_response_with_fixture(stanford_restricted_file_purl_xml)
        expect(Embed::Purl.new('12345').contents.first.files.all?(&:stanford_only?)).to be true
      end

      it 'identifies stanford_only no-download objects' do
        stub_purl_xml_response_with_fixture(stanford_no_download_restricted_file_purl_xml)
        expect(Embed::Purl.new('12345').contents.first.files.all?(&:stanford_only?)).to be true
      end

      it 'identifies world accessible objects as not stanford only' do
        stub_purl_xml_response_with_fixture(file_purl_xml)
        expect(Embed::Purl.new('12345').contents.first.files.all?(&:stanford_only?)).to be false
      end

      it 'identifies file-level stanford_only rights' do
        stub_purl_xml_response_with_fixture(stanford_restricted_multi_file_purl_xml)
        contents = Embed::Purl.new('12345').contents
        first_file = contents.first.files.first
        last_file = contents.last.files.first
        expect(first_file).to be_stanford_only
        expect(last_file).not_to be_stanford_only
      end
    end

    describe 'location_restricted?' do
      it 'identifies location restricted objects' do
        stub_purl_xml_response_with_fixture(single_video_purl)
        expect(Embed::Purl.new('12345').contents.first.files.all?(&:location_restricted?)).to be true
      end

      it 'identifies world accessible objects as not stanford only' do
        stub_purl_xml_response_with_fixture(file_purl_xml)
        expect(Embed::Purl.new('12345').contents.first.files.all?(&:location_restricted?)).to be false
      end

      it 'identifies file-level location_restricted rights' do
        stub_purl_xml_response_with_fixture(video_purl)
        contents = Embed::Purl.new('12345').contents
        first_file = contents.first.files.first
        last_file = contents.last.files.first
        expect(first_file).to be_location_restricted
        expect(last_file).not_to be_location_restricted
      end
    end

    describe 'world_downloadable?' do
      it 'is false for stanford-only objects' do
        stub_purl_xml_response_with_fixture(stanford_restricted_file_purl_xml)
        expect(Embed::Purl.new('12345').contents.first.files.all?(&:world_downloadable?)).to be false
      end

      it 'is false for no-download objects' do
        stub_purl_xml_response_with_fixture(stanford_no_download_restricted_file_purl_xml)
        expect(Embed::Purl.new('12345').contents.first.files.all?(&:world_downloadable?)).to be false
      end

      it 'is true for identify world accessible objects' do
        stub_purl_xml_response_with_fixture(file_purl_xml)
        expect(Embed::Purl.new('12345').contents.first.files.all?(&:world_downloadable?)).to be true
      end
    end
  end

  describe 'duration' do
    let(:rf) { described_class.new('123', 'desc', f, double('Rights')) }
    let(:f) { double('File') }

    it 'gets duration string from videoData' do
      video_data_el = Nokogiri::XML("<videoData duration='P0DT1H2M3S'/>").root
      expect(f).to receive(:xpath).with('./*/@duration').and_return(['something'])
      expect(f).to receive(:xpath).with('./*[@duration]').and_return([video_data_el])
      expect(Embed::MediaDuration).to receive(:new).and_call_original
      expect(rf.duration).to eq '1:02:03'
    end

    it 'gets duration string from audioData' do
      audio_data_el = Nokogiri::XML("<audioData duration='PT43S'/>").root
      expect(f).to receive(:xpath).with('./*/@duration').and_return(['something'])
      expect(f).to receive(:xpath).with('./*[@duration]').and_return([audio_data_el])
      expect(Embed::MediaDuration).to receive(:new).and_call_original
      expect(rf.duration).to eq '0:43'
    end

    it 'nil when missing media data element' do
      allow(f).to receive(:xpath)
      expect(Embed::MediaDuration).not_to receive(:new)
      expect(rf.duration).to be_nil
    end

    it 'invalid format returns nil and logs an error' do
      audio_data_el = Nokogiri::XML("<audioData duration='invalid'/>").root
      expect(f).to receive(:xpath).with('./*/@duration').and_return(['something'])
      expect(f).to receive(:xpath).with('./*[@duration]').and_return([audio_data_el])
      expect(Honeybadger).to receive(:notify).with("ResourceFile#media duration ISO8601::Errors::UnknownPattern: 'invalid'")
      expect(Embed::MediaDuration).to receive(:new).and_call_original
      expect(rf.duration).to be_nil
    end
  end

  describe '#vtt?' do
    subject { file.vtt? }

    context 'when it is a vtt transcript' do
      let(:file) { Embed::Purl.new('12345').contents.first.files.second }

      before { stub_purl_xml_response_with_fixture(video_purl_with_vtt) }

      it { is_expected.to be true }
    end

    context 'when it is not a vtt transcript' do
      let(:file) { Embed::Purl.new('12345').contents.first.files.first }

      before { stub_purl_xml_response_with_fixture(single_video_purl) }

      it { is_expected.to be false }
    end
  end
end
