require 'rails_helper'

describe Embed::PrettyFilesize do
  let(:dummy_class) { Class.new { include Embed::PrettyFilesize }.new }
  describe '.pretty_file_size' do
    it 'returns the correct size' do
      if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.4.0')
        # Gaussian rounding: https://blog.heroku.com/ruby-2-4-features-hashes-integers-rounding#gaussian-rounding
        expect(dummy_class.pretty_filesize(12_345)).to eq '12.34 kB'
      else
        expect(dummy_class.pretty_filesize(12_345)).to eq '12.35 kB'
      end
    end
  end
end
