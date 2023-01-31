# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::StacksImage do
  subject do
    Class.new do
      extend Embed::StacksImage
    end
  end

  describe '#stacks_image_url' do
    let(:stacks_image_url) { subject.stacks_image_url('abc123', 'filename.jpg') }

    it 'has the configured stacks host and IIIF path' do
      expect(stacks_image_url).to match(%r{^https://stacks\.stanford\.edu/image/iiif/})
    end

    it 'has the passed in druid' do
      expect(stacks_image_url).to match(%r{/abc123%2F})
    end

    it 'has the passed in file name normalized by dropping the extension' do
      expect(stacks_image_url).to match(/%2Ffilename$/)
    end
  end

  describe '#stacks_square_url' do
    let(:stacks_square_url) { subject.stacks_square_url('abc123', 'filename.jpg') }

    it 'requests a "square" url from the stacks image service' do
      expect(stacks_square_url).to match(%r{filename/square/})
    end

    it 'defaults to a 100px by 100px square' do
      expect(stacks_square_url).to match(%r{square/100,100/})
    end

    it 'accpets an optional size parameter' do
      expect(subject.stacks_square_url('abc123', 'filename.jpg', size: 50)).to match(%r{square/50,50/})
    end

    it 'escapes special characters in the image file name' do
      expect(subject.stacks_square_url('abc123', 'file name.jpg')).to match(/file%20name/)
    end
  end

  describe '#stacks_thumb_url' do
    it 'requests an image that is 400px on the long edge' do
      expect(subject.stacks_thumb_url('abc123', 'filename.jpg')).to match(%r{/full/!400,400/})
    end

    it 'escapes special characters in the image file name' do
      expect(subject.stacks_thumb_url('abc123', 'file name.jpg')).to match(/file%20name/)
    end
  end
end
