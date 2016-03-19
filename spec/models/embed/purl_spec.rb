require 'rails_helper'

describe Embed::PURL do
  include PURLFixtures
  describe 'title' do
    before { stub_purl_response_with_fixture(file_purl) }
    it 'gets the objectLabel from the identityMetadata' do
      expect(described_class.new('12345').title).to eq 'File Title'
    end
  end
  describe 'type' do
    before { stub_purl_response_with_fixture(file_purl) }
    it 'gets the type attribute from the content metadata' do
      expect(described_class.new('12345').type).to eq 'file'
    end
  end
  describe 'embargoed?' do
    it 'returns true when an item is embargoed' do
      stub_purl_response_with_fixture(embargoed_purl)
      expect(described_class.new('12345')).to be_embargoed
    end
    it 'returns false when an item is not embargoed' do
      stub_purl_response_with_fixture(file_purl)
      expect(described_class.new('12345')).to_not be_embargoed
    end
  end
  describe '#world_unrestricted?' do
    it 'without a world restriction' do
      stub_purl_response_with_fixture(image_purl)
      expect(described_class.new('12345')).to be_world_unrestricted
    end
    it 'when it has a world restriction' do
      stub_purl_response_with_fixture(stanford_restricted_image_purl)
      expect(described_class.new('12345')).to_not be_world_unrestricted
    end
  end
  describe 'embargo_release_date' do
    before { stub_purl_response_with_fixture(embargoed_purl) }
    it 'returns the date in the embargo field' do
      expect(described_class.new('12345').embargo_release_date).to match(/\d{4}-\d{2}-\d{2}/)
    end
  end
  describe 'contents' do
    it 'returns an array of resources' do
      stub_purl_response_with_fixture(file_purl)
      expect(described_class.new('12345').contents.all? do |resource|
        resource.is_a?(Embed::PURL::Resource)
      end).to be true
    end
  end
  describe 'all_resource_files' do
    it 'returns a flattened array of resource files' do
      stub_purl_response_with_fixture(multi_resource_multi_file_purl)
      expect(described_class.new('12345').all_resource_files.count).to eq 4
    end
  end
  describe '#bounding_box' do
    before { stub_purl_response_with_fixture(geo_purl_public) }
    it 'creates an Envelope and calls #to_bounding_box on it' do
      expect_any_instance_of(Embed::Envelope).to receive(:to_bounding_box)
      described_class.new('12345').bounding_box
    end
  end
  describe '#envelope' do
    it 'selects the envelope element' do
      stub_purl_response_with_fixture(geo_purl_public)
      expect(described_class.new('12345').envelope).to be_an Nokogiri::XML::Element
    end
    it 'without an envelope present' do
      stub_purl_response_with_fixture(image_purl)
      expect(described_class.new('12345').envelope).to be_nil
    end
  end
  describe 'licence' do
    it 'returns cc license if present' do
      stub_purl_response_with_fixture(file_purl)
      purl = described_class.new('12345')
      expect(purl.license[:human]).to eq 'CC Attribution Non-Commercial license'
      expect(purl.license[:machine]).to eq 'by-nc'
    end
    it 'returns odc license if present' do
      stub_purl_response_with_fixture(hybrid_object_purl)
      purl = described_class.new('12345')
      expect(purl.license[:human]).to eq 'ODC-By Attribution License'
      expect(purl.license[:machine]).to eq 'odc-by'
    end
    it 'returns nil if no license is present' do
      stub_purl_response_with_fixture(embargoed_purl)
      expect(described_class.new('12345').license).to eq nil
    end
  end
  describe 'public?' do
    it 'returns true if the object is publicly accessible' do
      stub_purl_response_with_fixture(file_purl)
      expect(described_class.new('12345').public?).to be_truthy
    end
    it 'returns false if the object is Stanford Only' do
      stub_purl_response_with_fixture(stanford_restricted_purl)
      expect(described_class.new('12345').public?).to be_falsy
    end
  end
  describe 'PURL::Resource' do
    it 'gets the sequence attribute' do
      stub_purl_response_with_fixture(file_purl)
      expect(described_class.new('12345').contents.first.sequence).to eq '1'
    end
    it 'gets the type attribute' do
      stub_purl_response_with_fixture(file_purl)
      expect(described_class.new('12345').contents.first.type).to eq 'file'
    end
    it 'gets the description from the label element' do
      stub_purl_response_with_fixture(file_purl)
      expect(described_class.new('12345').contents.first.description).to eq 'File1 Label'
    end
    it 'gets the description from the attr[name="label"] element' do
      stub_purl_response_with_fixture(multi_file_purl)
      expect(described_class.new('12345').contents.first.description).to eq 'Resource Label'
    end
    describe 'files' do
      it 'returns an array of PURL::Resource::ResourceFile objects' do
        stub_purl_response_with_fixture(file_purl)
        expect(described_class.new('12345').contents.first.files.all? do |resource_file|
          resource_file.is_a?(Embed::PURL::Resource::ResourceFile)
        end).to be true
      end
    end
    describe 'PURL::Resource::ResourceFile' do
      describe 'attributes' do
        before { stub_purl_response_with_fixture(file_purl) }
        let(:resource_file) { described_class.new('12345').contents.first.files.first }
        it 'gets the title from from the id attribute' do
          expect(resource_file.title).to eq 'Title of the PDF.pdf'
        end
        it 'gets the mimetype from the mimetype attribute' do
          expect(resource_file.mimetype).to eq 'application/pdf'
        end
        it 'gets the size from the size attribute' do
          expect(resource_file.size).to eq '12345'
        end
      end
      describe 'previewable?' do
        it 'returns true if the mimetype of the file is previewable' do
          stub_purl_response_with_fixture(image_purl)
          expect(described_class.new('12345').contents.first.files.first).to be_previewable
        end
        it 'returns false if the mimetype of the file is not previewable' do
          stub_purl_response_with_fixture(file_purl)
          expect(described_class.new('12345').contents.first.files.first).to_not be_previewable
        end
      end
      describe 'is_image?' do
        it 'returns true if the mimetype of the file is an image' do
          stub_purl_response_with_fixture(image_purl)
          expect(described_class.new('12345').contents.first.files.first).to be_is_image
        end
        it 'returns false if the mimetype of the file is not an image' do
          stub_purl_response_with_fixture(file_purl)
          expect(described_class.new('12345').contents.first.files.first).to_not be_is_image
        end
      end
      describe 'rights' do
        describe 'stanford_only?' do
          it 'identifies stanford_only objects' do
            stub_purl_response_with_fixture(stanford_restricted_purl)
            expect(described_class.new('12345').contents.first.files.all?(&:stanford_only?)).to be true
          end
          it 'identifies world accessible objects as not stanford only' do
            stub_purl_response_with_fixture(file_purl)
            expect(described_class.new('12345').contents.first.files.all?(&:stanford_only?)).to be false
          end
          it 'identifies file-level stanford_only rights' do
            stub_purl_response_with_fixture(stanford_restricted_file_purl)
            contents = described_class.new('12345').contents
            first_file = contents.first.files.first
            last_file = contents.last.files.first
            expect(first_file).to be_stanford_only
            expect(last_file).to_not be_stanford_only
          end
        end
      end
      describe 'image data' do
        before { stub_purl_response_with_fixture(image_purl) }
        let(:image) { described_class.new('12345').contents.first.files.first }
        it 'gets the image height and width for image objects' do
          expect(image.image_height).to eq '6123'
          expect(image.image_width).to eq '5321'
        end
      end
      describe 'file data' do
        before { stub_purl_response_with_fixture(file_purl) }
        let(:file) { described_class.new('12345').contents.first.files.first }
        it 'gets the location data when available' do
          expect(file.location).to eq 'http://stacks.stanford.edu/file/druid:abc123/Title_of_the_PDF.pdf'
        end
      end
    end
  end
end
