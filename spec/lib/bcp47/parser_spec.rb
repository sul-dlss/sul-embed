# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bcp47::Parser do
  subject(:parser) { described_class.new(input) }

  describe '#records' do
    subject(:records) { parser.records }

    context 'with an invalid record-jar string' do
      let(:input) { 'foobar' }

      it 'returns a list with an empty record' do
        expect(records).to include(instance_of(Bcp47::Record))
      end
    end

    context 'with a non-string' do
      let(:input) { ['foobar'] }

      it 'returns nil' do
        expect(records).to be_nil
      end
    end

    context 'with a legit record-jar string' do
      let(:input) { "File-Date: 2023-11-17\nOther-Field: foobar%%\nType: Language\nAdded: 2023-10-31" }

      it 'returns a list with two records' do
        expect(records.count).to eq(2)
        expect(records).to all(be_a(Bcp47::Record))
      end
    end
  end
end
