require 'rails_helper'

describe Embed::PrettyFilesize do
  let(:dummy_class) { Class.new { include Embed::PrettyFilesize }.new }
  describe '.pretty_file_size' do
    it 'should return the correct size' do
      expect(dummy_class.pretty_filesize(123_45)).to eq '12.35 kB'
    end
  end
end
