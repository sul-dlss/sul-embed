require 'rails_helper'

describe Embed::PrettyFilesize do
  let(:dummy_class) { Class.new }
  before { dummy_class.extend(described_class) }

  describe '.pretty_file_size' do
    it 'returns the correct size' do
      expect(dummy_class.pretty_filesize(123_45)).to eq '12.35 kB'
    end
  end
end
