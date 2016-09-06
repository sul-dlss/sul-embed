require 'rails_helper'

describe Embed::PURL do
  include PURLFixtures
  describe 'title' do
    before { stub_purl_response_with_fixture(file_purl) }
    it 'should get the objectLabel from the identityMetadata' do
      expect(Embed::PURL.new('12345').title).to eq 'File Title'
    end
  end
  describe 'type' do
    before { stub_purl_response_with_fixture(file_purl) }
    it 'should get the type attribute from the content metadata' do
      expect(Embed::PURL.new('12345').type).to eq 'file'
    end
  end
  describe 'embargoed?' do
    it 'should return true when an item is embargoed' do
      stub_purl_response_with_fixture(embargoed_file_purl)
      expect(Embed::PURL.new('12345')).to be_embargoed
    end
    it 'should return false when an item is not embargoed' do
      stub_purl_response_with_fixture(file_purl)
      expect(Embed::PURL.new('12345')).to_not be_embargoed
    end
  end
  describe '#world_unrestricted?' do
    it 'without a world restriction' do
      stub_purl_response_with_fixture(image_purl)
      expect(Embed::PURL.new('12345')).to be_world_unrestricted
    end
    it 'when it has a world restriction' do
      stub_purl_response_with_fixture(stanford_restricted_image_purl)
      expect(Embed::PURL.new('12345')).to_not be_world_unrestricted
    end
  end
  describe 'embargo_release_date' do
    before { stub_purl_response_with_fixture(embargoed_file_purl) }
    it 'should return the date in the embargo field' do
      expect(Embed::PURL.new('12345').embargo_release_date).to match(/\d{4}-\d{2}-\d{2}/)
    end
  end

  describe 'valid?' do
    context 'with empty content metadata' do
      before { stub_purl_response_with_fixture(empty_content_metadata_purl) }

      it 'is false' do
        expect(Embed::PURL.new('12345')).not_to be_valid
      end
    end

    context 'with content metadata' do
      before { stub_purl_response_with_fixture(file_purl) }

      it 'is true' do
        expect(Embed::PURL.new('12345')).to be_valid
      end
    end
  end

  describe 'contents' do
    it 'should return an array of resources' do
      stub_purl_response_with_fixture(file_purl)
      expect(Embed::PURL.new('12345').contents.all? do |resource|
        resource.is_a?(Embed::PURL::Resource)
      end).to be true
    end
  end
  describe 'all_resource_files' do
    it 'should return a flattened array of resource files' do
      stub_purl_response_with_fixture(multi_resource_multi_type_purl)
      expect(Embed::PURL.new('12345').all_resource_files.count).to eq 4
    end
  end
  describe '#bounding_box' do
    before { stub_purl_response_with_fixture(geo_purl_public) }
    it 'creates an Envelope and calls #to_bounding_box on it' do
      expect_any_instance_of(Embed::Envelope).to receive(:to_bounding_box)
      Embed::PURL.new('12345').bounding_box
    end
  end
  describe '#envelope' do
    it 'selects the envelope element' do
      stub_purl_response_with_fixture(geo_purl_public)
      expect(Embed::PURL.new('12345').envelope).to be_an Nokogiri::XML::Element
    end
    it 'without an envelope present' do
      stub_purl_response_with_fixture(image_purl)
      expect(Embed::PURL.new('12345').envelope).to be_nil
    end
  end
  describe 'licence' do
    it 'should return cc license if present' do
      stub_purl_response_with_fixture(file_purl)
      purl = Embed::PURL.new('12345')
      expect(purl.license[:human]).to eq 'CC Attribution Non-Commercial license'
      expect(purl.license[:machine]).to eq 'by-nc'
    end
    it 'should return odc license if present' do
      stub_purl_response_with_fixture(hybrid_object_purl)
      purl = Embed::PURL.new('12345')
      expect(purl.license[:human]).to eq 'ODC-By Attribution License'
      expect(purl.license[:machine]).to eq 'odc-by'
    end
    it 'should return nil if no license is present' do
      stub_purl_response_with_fixture(embargoed_file_purl)
      expect(Embed::PURL.new('12345').license).to eq nil
    end
  end
  describe 'public?' do
    it 'should return true if the object is publicly accessible' do
      stub_purl_response_with_fixture(file_purl)
      expect(Embed::PURL.new('12345').public?).to be_truthy
    end
    it 'should return false if the object is Stanford Only' do
      stub_purl_response_with_fixture(stanford_restricted_file_purl)
      expect(Embed::PURL.new('12345').public?).to be_falsy
    end
  end
  describe 'PURL::Resource' do
    it 'should get the sequence attribute' do
      stub_purl_response_with_fixture(file_purl)
      expect(Embed::PURL.new('12345').contents.first.sequence).to eq '1'
    end
    it 'should get the type attribute' do
      stub_purl_response_with_fixture(file_purl)
      expect(Embed::PURL.new('12345').contents.first.type).to eq 'file'
    end
    it 'should get the description from the label element' do
      stub_purl_response_with_fixture(file_purl)
      expect(Embed::PURL.new('12345').contents.first.description).to eq 'File1 Label'
    end
    it 'should get the description from the attr[name="label"] element' do
      stub_purl_response_with_fixture(multi_file_purl)
      expect(Embed::PURL.new('12345').contents.first.description).to eq 'File1 Label'
    end
    describe 'files' do
      it 'should return an array of PURL::Resource::ResourceFile objects' do
        stub_purl_response_with_fixture(file_purl)
        expect(Embed::PURL.new('12345').contents.first.files.all? do |resource_file|
          resource_file.is_a?(Embed::PURL::Resource::ResourceFile)
        end).to be true
      end
    end
    describe 'PURL::Resource::ResourceFile' do
      describe 'attributes' do
        before { stub_purl_response_with_fixture(file_purl) }
        let(:resource_file) { Embed::PURL.new('12345').contents.first.files.first }
        it 'should get the title from from the id attribute' do
          expect(resource_file.title).to eq 'Title of the PDF.pdf'
        end
        it 'should get the mimetype from the mimetype attribute' do
          expect(resource_file.mimetype).to eq 'application/pdf'
        end
        it 'should get the size from the size attribute' do
          expect(resource_file.size).to eq '12345'
        end
      end

      describe '#label' do
        let(:resource) { double('PURL::Resource', description: nil) }
        let(:resource_with_description) { double('PURL::Resource', description: 'The Resource Description') }
        let(:resource_file) { double('file', attributes: { 'id' => double(value: 'The File ID') }) }
        it 'is the resource description when available' do
          file = Embed::PURL::Resource::ResourceFile.new(resource_with_description, resource_file, double('rights'))
          expect(file.label).to eq 'The Resource Description'
        end

        it 'is the file id when no resource description is available' do
          file = Embed::PURL::Resource::ResourceFile.new(resource, resource_file, double('rights'))
          expect(file.label).to eq 'The File ID'
        end
      end

      describe 'previewable?' do
        it 'should return true if the mimetype of the file is previewable' do
          stub_purl_response_with_fixture(image_purl)
          expect(Embed::PURL.new('12345').contents.first.files.first).to be_previewable
        end
        it 'should return false if the mimetype of the file is not previewable' do
          stub_purl_response_with_fixture(file_purl)
          expect(Embed::PURL.new('12345').contents.first.files.first).to_not be_previewable
        end
      end
      describe 'image?' do
        it 'should return true if the mimetype of the file is an image' do
          stub_purl_response_with_fixture(image_purl)
          expect(Embed::PURL.new('12345').contents.first.files.first).to be_image
        end
        it 'should return false if the mimetype of the file is not an image' do
          stub_purl_response_with_fixture(file_purl)
          expect(Embed::PURL.new('12345').contents.first.files.first).to_not be_image
        end
      end
      describe 'rights' do
        describe 'stanford_only?' do
          it 'should identify stanford_only objects' do
            stub_purl_response_with_fixture(stanford_restricted_file_purl)
            expect(Embed::PURL.new('12345').contents.first.files.all?(&:stanford_only?)).to be true
          end
          it 'should identify world accessible objects as not stanford only' do
            stub_purl_response_with_fixture(file_purl)
            expect(Embed::PURL.new('12345').contents.first.files.all?(&:stanford_only?)).to be false
          end
          it 'should identify file-level stanford_only rights' do
            stub_purl_response_with_fixture(stanford_restricted_multi_file_purl)
            contents = Embed::PURL.new('12345').contents
            first_file = contents.first.files.first
            last_file = contents.last.files.first
            expect(first_file).to be_stanford_only
            expect(last_file).to_not be_stanford_only
          end
        end
        describe 'location_restricted?' do
          it 'should identify location restricted objects' do
            stub_purl_response_with_fixture(single_video_purl)
            expect(Embed::PURL.new('12345').contents.first.files.all?(&:location_restricted?)).to be true
          end
          it 'should identify world accessible objects as not stanford only' do
            stub_purl_response_with_fixture(file_purl)
            expect(Embed::PURL.new('12345').contents.first.files.all?(&:location_restricted?)).to be false
          end
          it 'should identify file-level location_restricted rights' do
            stub_purl_response_with_fixture(video_purl)
            contents = Embed::PURL.new('12345').contents
            first_file = contents.first.files.first
            last_file = contents.last.files.first
            expect(first_file).to be_location_restricted
            expect(last_file).to_not be_location_restricted
          end
        end
      end
      describe 'image data' do
        before { stub_purl_response_with_fixture(image_purl) }
        let(:image) { Embed::PURL.new('12345').contents.first.files.first }
        it 'should get the image height and width for image objects' do
          expect(image.image_height).to eq '6123'
          expect(image.image_width).to eq '5321'
        end
      end
      describe 'file data' do
        before { stub_purl_response_with_fixture(file_purl) }
        let(:file) { Embed::PURL.new('12345').contents.first.files.first }
        it 'should get the location data when available' do
          expect(file.location).to eq 'http://stacks.stanford.edu/file/druid:abc123/Title_of_the_PDF.pdf'
        end
      end
      describe 'video_data' do
        context 'valid videoData' do
          before { stub_purl_response_with_fixture(multi_media_purl) }
          let(:video) { Embed::PURL.new('12345').contents.first.files.first }
          it 'should get the height and width for the video object' do
            expect(video.video_height).to eq '288'
            expect(video.video_width).to eq '352'
          end
          it 'should get the duration for the video object' do
            expect(video.video_duration.to_s).to eq '1:02:03'
          end
        end
        context 'duration in an invalid format' do
          before { stub_purl_response_with_fixture(invalid_video_duration_purl) }
          let(:video) { Embed::PURL.new('12345').contents.first.files.first }
          it 'should return nil and log an error' do
            expect(Honeybadger).to receive(:notify).with("ResourceFile\#video_duration ISO8601::Errors::UnknownPattern: 'PDDTMMS'")
            expect(video.video_duration).to be_nil
          end
        end
      end
    end
    describe 'PURL::Duration' do
      it '#to_s should return the appropriate human-readable string for the given iso8601 duration string' do
        expect(Embed::PURL::Duration.new('P0DT1H2M3S').to_s).to eq '1:02:03'
        expect(Embed::PURL::Duration.new('PT2M3S').to_s).to     eq '2:03'
        expect(Embed::PURL::Duration.new('PT10S').to_s).to      eq '0:10'
        expect(Embed::PURL::Duration.new('P5DT1H2M3S').to_s).to eq '5:01:02:03'
        expect(Embed::PURL::Duration.new('P9D').to_s).to        eq '9:00:00:00'
      end
      it '#to_s should return nil and log the appropriate error for an unsupported Duration specification' do
        expect(Honeybadger).to receive(:notify).with('Embed::PURL::Duration does not support specifying durations in weeks')
        expect(Honeybadger).to receive(:notify).with('Embed::PURL::Duration does not support specifying negative durations')
        expect(Embed::PURL::Duration.new('P10W').to_s).to be_nil
        expect(Embed::PURL::Duration.new('-PT10S').to_s).to be_nil
      end
    end
  end
end
