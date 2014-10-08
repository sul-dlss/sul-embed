require "rails_helper"

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
      stub_purl_response_with_fixture(embargoed_purl)
      expect(Embed::PURL.new('12345')).to be_embargoed
    end
    it 'should return false when an item is not embargoed' do
      stub_purl_response_with_fixture(file_purl)
      expect(Embed::PURL.new('12345')).to_not be_embargoed
    end
  end
  describe 'embargo_release_date' do
    before { stub_purl_response_with_fixture(embargoed_purl) }
    it 'should return the date in the embargo field' do
      expect(Embed::PURL.new('12345').embargo_release_date).to match /\d{4}-\d{2}-\d{2}/
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
      expect(Embed::PURL.new('12345').contents.first.description).to eq 'Resource Label'
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
      describe 'rights' do
        describe 'stanford_only?' do
          it 'should identify stanford_only objects' do
            stub_purl_response_with_fixture(stanford_restricted_purl)
            expect(Embed::PURL.new('12345').contents.first.files.all?(&:stanford_only?)).to be true
          end
          it 'should identify world accessible objects as not stanford only' do
            stub_purl_response_with_fixture(file_purl)
            expect(Embed::PURL.new('12345').contents.first.files.all?(&:stanford_only?)).to be false
          end
          pending 'should identify file-level stanford_only rights' do
            stub_purl_response_with_fixture(stanford_restricted_file_purl)
            files = Embed::PURL.new('12345').contents.first.files
            expect(files.first).to be_stanford_only
            expect(files.last).to_not be_stanford_only
          end
        end
      end
      describe 'image data' do
        before { stub_purl_response_with_fixture(image_purl) }
        let(:image) { Embed::PURL.new('12345').contents.first.files.first }
        it 'should get the image height and width for image objects' do
          expect(image.image_height).to eq '123'
          expect(image.image_width).to eq '321'
        end
      end
      describe 'file data' do
        before { stub_purl_response_with_fixture(file_purl) }
        let(:file) { Embed::PURL.new('12345').contents.first.files.first }
        it 'should get the location data when available' do
          expect(file.location).to eq 'http://stacks.stanford.edu/file/druid:abc123/Title_of_the_PDF.pdf'
        end
      end
    end
  end
end
