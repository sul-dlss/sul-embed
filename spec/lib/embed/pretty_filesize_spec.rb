# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::PrettyFilesize do
  let(:dummy_class) { Class.new { include Embed::PrettyFilesize }.new }

  describe '.pretty_file_size' do
    subject { dummy_class.pretty_filesize(size) }

    context 'kilobyte scale' do
      let(:size) { 12_345 }

      it { is_expected.to eq '12.35 kB' }
    end

    context 'megabyte scale' do
      let(:size) { 4_761_613 }

      it { is_expected.to eq '4.76 MB' }
    end
  end
end
