# frozen_string_literal: true

require 'rails_helper'

describe Embed::Purl do
  include PurlFixtures
  describe 'title' do
    before { stub_purl_response_with_fixture(file_purl) }
    it 'should get the objectLabel from the identityMetadata' do
      expect(Embed::Purl.new('12345').title).to eq 'File Title'
    end
  end
  describe 'type' do
    before { stub_purl_response_with_fixture(file_purl) }
    it 'should get the type attribute from the content metadata' do
      expect(Embed::Purl.new('12345').type).to eq 'file'
    end
  end
  describe 'embargoed?' do
    it 'should return true when an item is embargoed' do
      stub_purl_response_with_fixture(embargoed_file_purl)
      expect(Embed::Purl.new('12345')).to be_embargoed
    end
    it 'should return false when an item is not embargoed' do
      stub_purl_response_with_fixture(file_purl)
      expect(Embed::Purl.new('12345')).to_not be_embargoed
    end
  end
  describe '#world_unrestricted?' do
    it 'without a world restriction' do
      stub_purl_response_with_fixture(image_purl)
      expect(Embed::Purl.new('12345')).to be_world_unrestricted
    end
    it 'when it has a world restriction' do
      stub_purl_response_with_fixture(stanford_restricted_image_purl)
      expect(Embed::Purl.new('12345')).to_not be_world_unrestricted
    end
  end
  describe 'embargo_release_date' do
    before { stub_purl_response_with_fixture(embargoed_file_purl) }
    it 'should return the date in the embargo field' do
      expect(Embed::Purl.new('12345').embargo_release_date).to match(/\d{4}-\d{2}-\d{2}/)
    end
  end

  describe 'valid?' do
    context 'with empty content metadata' do
      before { stub_purl_response_with_fixture(empty_content_metadata_purl) }

      it 'is false' do
        expect(Embed::Purl.new('12345')).not_to be_valid
      end
    end

    context 'with content metadata' do
      before { stub_purl_response_with_fixture(file_purl) }

      it 'is true' do
        expect(Embed::Purl.new('12345')).to be_valid
      end
    end
  end

  describe '#collections' do
    it 'formats a list of collection druids' do
      stub_purl_response_with_fixture(was_seed_purl)
      expect(Embed::Purl.new('12345').collections).to eq ['mk656nf8485']
    end
    it 'is empty when no collection is present in xml' do
      stub_purl_response_with_fixture(file_purl)
      expect(Embed::Purl.new('12345').collections).to eq []
    end
  end

  describe 'contents' do
    it 'should return an array of resources' do
      stub_purl_response_with_fixture(file_purl)
      expect(Embed::Purl.new('12345').contents.all?(Embed::Purl::Resource)).to be true
    end
  end
  describe 'all_resource_files' do
    it 'should return a flattened array of resource files' do
      stub_purl_response_with_fixture(multi_resource_multi_type_purl)
      df = Embed::Purl.new('12345').all_resource_files
      expect(df).to be_an_instance_of Array
      expect(df.first).to be_an_instance_of Embed::Purl::Resource::ResourceFile
      expect(df.count).to eq 4
    end
  end
  describe '#downloadable_files' do
    it 'returns a flattened array of downloadable resource files' do
      stub_purl_response_with_fixture(multi_resource_multi_type_purl)
      df = Embed::Purl.new('12345').downloadable_files
      expect(df).to be_an_instance_of Array
      expect(df.first).to be_an_instance_of Embed::Purl::Resource::ResourceFile
      expect(df.count).to eq 4
    end
    it 'returns only downloadable files (world)' do
      stub_purl_response_with_fixture(world_restricted_download_purl)
      purl_obj = Embed::Purl.new('12345')
      expect(purl_obj.all_resource_files.count).to eq 3
      expect(purl_obj.downloadable_files.count).to eq 1
    end
    it 'returns only downloadable files (stanford)' do
      stub_purl_response_with_fixture(stanford_restricted_download_purl)
      purl_obj = Embed::Purl.new('5678')
      expect(purl_obj.all_resource_files.count).to eq 3
      expect(purl_obj.downloadable_files.count).to eq 2
    end
  end
  describe '#bounding_box' do
    before { stub_purl_response_with_fixture(geo_purl_public) }
    it 'creates an Envelope and calls #to_bounding_box on it' do
      expect_any_instance_of(Embed::Envelope).to receive(:to_bounding_box)
      Embed::Purl.new('12345').bounding_box
    end
  end
  describe '#envelope' do
    it 'selects the envelope element' do
      stub_purl_response_with_fixture(geo_purl_public)
      expect(Embed::Purl.new('12345').envelope).to be_an Nokogiri::XML::Element
    end
    it 'without an envelope present' do
      stub_purl_response_with_fixture(image_purl)
      expect(Embed::Purl.new('12345').envelope).to be_nil
    end
  end
  describe 'license' do
    it 'should return cc license if present' do
      stub_purl_response_with_fixture(file_purl)
      purl = Embed::Purl.new('12345')
      expect(purl.license).to eq 'Public Domain Mark 1.0'
    end
    it 'should return odc license if present' do
      stub_purl_response_with_fixture(hybrid_object_purl)
      purl = Embed::Purl.new('12345')
      expect(purl.license).to eq 'ODC-By Attribution License'
    end
    it 'should return MODS license if present' do
      stub_purl_response_with_fixture(mods_license_purl)
      purl = Embed::Purl.new('12345')
      expect(purl.license).to eq 'This work is licensed under an Apache License 2.0 license.'
    end
    it 'should return nil if no license is present' do
      stub_purl_response_with_fixture(embargoed_file_purl)
      expect(Embed::Purl.new('12345').license).to eq nil
    end
  end
  describe 'public?' do
    it 'should return true if the object is publicly accessible' do
      stub_purl_response_with_fixture(file_purl)
      expect(Embed::Purl.new('12345').public?).to be_truthy
    end
    it 'should return false if the object is Stanford Only' do
      stub_purl_response_with_fixture(stanford_restricted_file_purl)
      expect(Embed::Purl.new('12345').public?).to be_falsy
    end
  end

  describe 'Purl::Resource' do
    it 'should get the type attribute' do
      stub_purl_response_with_fixture(file_purl)
      expect(Embed::Purl.new('12345').contents.first.type).to eq 'file'
    end
    it 'should get the description from the label element' do
      stub_purl_response_with_fixture(file_purl)
      expect(Embed::Purl.new('12345').contents.first.description).to eq 'File1 Label'
    end
    it 'should get the description from the attr[name="label"] element' do
      stub_purl_response_with_fixture(multi_file_purl)
      expect(Embed::Purl.new('12345').contents.first.description).to eq 'File1 Label'
    end

    describe '#object_thumbnail?' do
      let(:purl_resource) { double('Resource') }
      it 'is true when type="thumb"' do
        allow(purl_resource).to receive(:attributes).and_return('type' => double(value: 'thumb'))
        expect(Embed::Purl::Resource.new(purl_resource, double('Rights'))).to be_object_thumbnail
      end

      it 'is true when thumb="yes"' do
        allow(purl_resource).to receive(:attributes).and_return('thumb' => double(value: 'yes'))
        expect(Embed::Purl::Resource.new(purl_resource, double('Rights'))).to be_object_thumbnail
      end

      it 'is false otherwise' do
        allow(purl_resource).to receive(:attributes).and_return('type' => double(value: 'image'))
        expect(Embed::Purl::Resource.new(purl_resource, double('Rights'))).not_to be_object_thumbnail
      end
    end

    describe 'files' do
      it 'should return an array of Purl::Resource::ResourceFile objects' do
        stub_purl_response_with_fixture(file_purl)
        expect(Embed::Purl.new('12345').contents.first.files.all?(Embed::Purl::Resource::ResourceFile)).to be true
      end
    end

    describe '#manifest_json_url' do
      it 'constructs a URL to a IIIF manifest' do
        expect(Embed::Purl.new('12345').manifest_json_url).to eq 'https://purl.stanford.edu/12345/iiif/manifest'
      end
    end

    describe '#manifest_json_response' do
      it 'fetches the IIIF manifest' do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(instance_double(Faraday::Response, body: '{}', success?: true))
        expect(Embed::Purl.new('12345').manifest_json_response).to eq '{}'
      end

      it 'raises an application error on failure' do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(instance_double(Faraday::Response, success?: false))
        expect { Embed::Purl.new('12345').manifest_json_response }.to raise_error(Embed::Purl::ResourceNotAvailable)
      end

      it 'raises an application error on timeout' do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(Faraday::ConnectionFailed.new(''))
        expect { Embed::Purl.new('12345').manifest_json_response }.to raise_error(Embed::Purl::ResourceNotAvailable)
      end
    end

    describe 'Purl::Resource::ResourceFile' do
      describe 'attributes' do
        before { stub_purl_response_with_fixture(file_purl) }
        let(:resource_file) { Embed::Purl.new('12345').contents.first.files.first }
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
        let(:resource) { double('Purl::Resource', description: nil) }
        let(:resource_with_description) { double('Purl::Resource', description: 'The Resource Description') }
        let(:resource_file) { double('file', attributes: { 'id' => double(value: 'The File ID') }) }
        it 'is the resource description when available' do
          file = Embed::Purl::Resource::ResourceFile.new(resource_with_description, resource_file, double('rights'))
          expect(file.label).to eq 'The Resource Description'
        end

        it 'is the file id when no resource description is available' do
          file = Embed::Purl::Resource::ResourceFile.new(resource, resource_file, double('rights'))
          expect(file.label).to eq 'The File ID'
        end
      end

      describe '#thumbnail' do
        let(:resource_with_thumb) do
          double(
            'Purl::Resource', files: [
              double(thumbnail?: false, title: 'Non thumb'),
              double(thumbnail?: true, title: 'The Thumb')
            ]
          )
        end
        let(:resource_without_thumb) do
          double(
            'Purl::Resource', files: [
              double(thumbnail?: false, title: 'Non thumb'),
              double(thumbnail?: false, title: 'Another Non Thumb')
            ]
          )
        end

        it 'is the thumbnail within the same resource' do
          file = Embed::Purl::Resource::ResourceFile.new(resource_with_thumb, double('File'), double('Rights'))
          expect(file.thumbnail.title).to eq 'The Thumb'
        end

        it 'is nil when the resource does not have a file specific thumb' do
          file = Embed::Purl::Resource::ResourceFile.new(resource_without_thumb, double('File'), double('Rights'))
          expect(file.thumbnail).to be_nil
        end
      end

      describe '#thumbnail?' do
        let(:resource) { double('Resource') }
        let(:file) { double('File') }
        let(:resource_file) { Embed::Purl::Resource::ResourceFile.new(resource, file, double('Rights')) }

        it 'is true when the parent resource is an object level thumbnail' do
          allow(resource).to receive(:object_thumbnail?).and_return(true)
          expect(resource_file).to be_thumbnail
        end

        it 'is false when the file is not an image' do
          allow(resource).to receive(:object_thumbnail?).and_return(false)
          allow(file).to receive(:attributes).and_return('mimetype' => double(value: 'not-an-image'))
          expect(resource_file).not_to be_thumbnail
        end

        it 'is true when the parent resource type is whitelisted as having file-level thumbnail behaviors (and it is an image)' do
          allow(resource).to receive(:object_thumbnail?).and_return(false)
          allow(resource).to receive(:type).and_return('video')
          allow(file).to receive(:attributes).and_return('mimetype' => double(value: 'image/jp2'))
          expect(resource_file).to be_thumbnail
        end

        it 'is false when the parent resource type is not whitelisted as having file-level thumbnail behaviors (even if it is an image)' do
          allow(resource).to receive(:object_thumbnail?).and_return(false)
          allow(resource).to receive(:type).and_return('book')
          allow(file).to receive(:attributes).and_return('mimetype' => double(value: 'image/jp2'))
          expect(resource_file).not_to be_thumbnail
        end
      end

      describe 'previewable?' do
        it 'should return true if the mimetype of the file is previewable' do
          stub_purl_response_with_fixture(image_purl)
          expect(Embed::Purl.new('12345').contents.first.files.first).to be_previewable
        end
        it 'should return false if the mimetype of the file is not previewable' do
          stub_purl_response_with_fixture(file_purl)
          expect(Embed::Purl.new('12345').contents.first.files.first).to_not be_previewable
        end
      end
      describe 'image?' do
        it 'should return true if the mimetype of the file is an image' do
          stub_purl_response_with_fixture(image_purl)
          expect(Embed::Purl.new('12345').contents.first.files.first).to be_image
        end
        it 'should return false if the mimetype of the file is not an image' do
          stub_purl_response_with_fixture(file_purl)
          expect(Embed::Purl.new('12345').contents.first.files.first).to_not be_image
        end
      end
      describe 'rights' do
        describe 'stanford_only?' do
          it 'should identify stanford_only objects' do
            stub_purl_response_with_fixture(stanford_restricted_file_purl)
            expect(Embed::Purl.new('12345').contents.first.files.all?(&:stanford_only?)).to be true
          end
          it 'should identify stanford_only no-download objects' do
            stub_purl_response_with_fixture(stanford_no_download_restricted_file_purl)
            expect(Embed::Purl.new('12345').contents.first.files.all?(&:stanford_only?)).to be true
          end
          it 'should identify world accessible objects as not stanford only' do
            stub_purl_response_with_fixture(file_purl)
            expect(Embed::Purl.new('12345').contents.first.files.all?(&:stanford_only?)).to be false
          end
          it 'should identify file-level stanford_only rights' do
            stub_purl_response_with_fixture(stanford_restricted_multi_file_purl)
            contents = Embed::Purl.new('12345').contents
            first_file = contents.first.files.first
            last_file = contents.last.files.first
            expect(first_file).to be_stanford_only
            expect(last_file).to_not be_stanford_only
          end
        end
        describe 'location_restricted?' do
          it 'should identify location restricted objects' do
            stub_purl_response_with_fixture(single_video_purl)
            expect(Embed::Purl.new('12345').contents.first.files.all?(&:location_restricted?)).to be true
          end
          it 'should identify world accessible objects as not stanford only' do
            stub_purl_response_with_fixture(file_purl)
            expect(Embed::Purl.new('12345').contents.first.files.all?(&:location_restricted?)).to be false
          end
          it 'should identify file-level location_restricted rights' do
            stub_purl_response_with_fixture(video_purl)
            contents = Embed::Purl.new('12345').contents
            first_file = contents.first.files.first
            last_file = contents.last.files.first
            expect(first_file).to be_location_restricted
            expect(last_file).to_not be_location_restricted
          end
        end

        describe 'world_downloadable?' do
          it 'is false for stanford-only objects' do
            stub_purl_response_with_fixture(stanford_restricted_file_purl)
            expect(Embed::Purl.new('12345').contents.first.files.all?(&:world_downloadable?)).to be false
          end
          it 'is false for no-download objects' do
            stub_purl_response_with_fixture(stanford_no_download_restricted_file_purl)
            expect(Embed::Purl.new('12345').contents.first.files.all?(&:world_downloadable?)).to be false
          end
          it 'is true for identify world accessible objects' do
            stub_purl_response_with_fixture(file_purl)
            expect(Embed::Purl.new('12345').contents.first.files.all?(&:world_downloadable?)).to be true
          end
        end
      end
      describe 'image data' do
        before { stub_purl_response_with_fixture(image_purl) }
        let(:image) { Embed::Purl.new('12345').contents.first.files.first }
        it 'should get the image height and width for image objects' do
          expect(image.height).to eq '6123'
          expect(image.width).to eq '5321'
        end
      end
      describe 'file data' do
        before { stub_purl_response_with_fixture(file_purl) }
        let(:file) { Embed::Purl.new('12345').contents.first.files.first }
        it 'should get the location data when available' do
          expect(file.location).to eq 'http://stacks.stanford.edu/file/druid:abc123/Title_of_the_PDF.pdf'
        end
      end
      describe 'duration' do
        it 'gets duration string from videoData' do
          f = double('File')
          video_data_el = Nokogiri::XML("<videoData duration='P0DT1H2M3S'/>").root
          expect(f).to receive(:xpath).with('./*/@duration').and_return(['something'])
          expect(f).to receive(:xpath).with('./*[@duration]').and_return([video_data_el])
          rf = Embed::Purl::Resource::ResourceFile.new(double('Resource'), f, double('Rights'))
          expect(Embed::MediaDuration).to receive(:new).and_call_original
          expect(rf.duration).to eq '1:02:03'
        end
        it 'gets duration string from audioData' do
          f = double('File')
          audio_data_el = Nokogiri::XML("<audioData duration='PT43S'/>").root
          expect(f).to receive(:xpath).with('./*/@duration').and_return(['something'])
          expect(f).to receive(:xpath).with('./*[@duration]').and_return([audio_data_el])
          rf = Embed::Purl::Resource::ResourceFile.new(double('Resource'), f, double('Rights'))
          expect(Embed::MediaDuration).to receive(:new).and_call_original
          expect(rf.duration).to eq '0:43'
        end
        it 'nil when missing media data element' do
          f = double('File')
          allow(f).to receive(:xpath)
          rf = Embed::Purl::Resource::ResourceFile.new(double('Resource'), f, double('Rights'))
          expect(Embed::MediaDuration).not_to receive(:new)
          expect(rf.duration).to eq nil
        end
        it 'invalid format returns nil and logs an error' do
          f = double('File')
          audio_data_el = Nokogiri::XML("<audioData duration='invalid'/>").root
          expect(f).to receive(:xpath).with('./*/@duration').and_return(['something'])
          expect(f).to receive(:xpath).with('./*[@duration]').and_return([audio_data_el])
          rf = Embed::Purl::Resource::ResourceFile.new(double('Resource'), f, double('Rights'))
          expect(Honeybadger).to receive(:notify).with("ResourceFile\#media duration ISO8601::Errors::UnknownPattern: 'invalid'")
          expect(Embed::MediaDuration).to receive(:new).and_call_original
          expect(rf.duration).to eq nil
        end
      end
      describe 'video_data' do
        context 'valid videoData' do
          before { stub_purl_response_with_fixture(multi_media_purl) }
          let(:video) { Embed::Purl.new('12345').contents.first.files.first }
          it 'should get the height and width for the video object' do
            expect(video.height).to eq '288'
            expect(video.width).to eq '352'
          end
        end
      end
    end
  end
end
