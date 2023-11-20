# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bcp47::Record do
  subject(:record) { described_class.new(attrs) }

  describe '.parse' do
    subject(:record) { described_class.parse(record_string) }

    let(:record_string) { "Description: This is the first line\n  and this is the second\n  and this is the third\nType: language\nAdded: 2023-10-31\nDescription: A simple one\n%%\n" }

    it 'concatenates continued lines and ignores record separator lines' do
      expect(record.description.last).to eq('A simple one')
      expect(record.description.first).to eq('This is the first line and this is the second and this is the third')
    end
  end

  describe 'attr_readers' do
    (described_class::KNOWN_FIELDS - described_class::DATE_FIELDS).each do |field|
      context "when #{field} field is in attrs" do
        let(:attrs) { [[field.split('_').map(&:capitalize).join('-'), value]] }
        let(:value) { 'a scintillating value' }

        it 'returns the expected value' do
          expect(record.public_send(field)).to eq(value)
        end
      end

      context "when #{field} field is not in attrs" do
        let(:attrs) { [[]] }

        it 'returns nil' do
          expect(record.public_send(field)).to be_nil
        end
      end
    end

    described_class::DATE_FIELDS.each do |field|
      context "when #{field} field is in attrs" do
        let(:attrs) { [[field.split('_').map(&:capitalize).join('-'), value]] }
        let(:value) { '2022-05-07' }

        it 'returns the expected value' do
          expect(record.public_send(field)).to eq(Date.parse(value))
        end
      end

      context "when #{field} field is not in attrs" do
        let(:attrs) { [[]] }

        it 'returns nil' do
          expect(record.public_send(field)).to be_nil
        end
      end
    end
  end

  # NOTE: This block uses the `Suppress-Script` field as an arbitrary example, but this
  #       behavior works identically for all known fields.
  describe 'setters' do
    before { record.suppress_script = new_value }

    context 'when setting a field with no current value' do
      let(:attrs) { [[]] }
      let(:new_value) { 'first value' }

      it 'sets the value as a string' do
        expect(record.suppress_script).to eq('first value')
      end
    end

    context 'when setting a field with a current scalar value' do
      let(:attrs) { [['Suppress-Script', 'first value']] }
      let(:new_value) { 'second value' }

      it 'sets the value as an array with the current value and the new value' do
        expect(record.suppress_script).to eq(['first value', 'second value'])
      end
    end

    context 'when setting a field with a current array value' do
      let(:attrs) { [['Suppress-Script', ['first value', 'second value']]] }
      let(:new_value) { 'third value' }

      it 'appends the new value to the current array' do
        expect(record.suppress_script).to eq(['first value', 'second value', 'third value'])
      end
    end
  end

  describe '#label' do
    context 'with no descriptions' do
      let(:attrs) { [[]] }

      it 'returns nil' do
        expect(record.label).to be_nil
      end
    end

    context 'with one description' do
      let(:attrs) { [['Description', 'English, US']] }

      it 'returns the sole description' do
        expect(record.label).to eq('English, US')
      end
    end

    context 'with multiple descriptions' do
      let(:attrs) { [['Description', 'English, US'], ['Description', 'Seattle, Washington']] }

      it 'returns the first description' do
        expect(record.label).to eq('English, US')
      end
    end
  end

  describe '#empty?' do
    context 'with no fields' do
      let(:attrs) { [[]] }

      it 'returns true' do
        expect(record).to be_empty
      end
    end

    context 'with one or more bogus fields set' do
      let(:attrs) { [['Descriptionzzz', 'English, US']] }

      it 'returns true' do
        expect(record).to be_empty
      end
    end

    context 'with one or more known fields set' do
      let(:attrs) { [['Description', 'English, US'], ['Type', 'language']] }

      it 'returns false' do
        expect(record).not_to be_empty
      end
    end
  end

  describe '#code' do
    context 'with no tags or subtags' do
      let(:attrs) { [[]] }

      it 'returns nil' do
        expect(record.code).to be_nil
      end
    end

    context 'with a subtag' do
      let(:attrs) { [%w[Subtag de]] }

      it 'returns the subtag' do
        expect(record.code).to eq('de')
      end
    end

    context 'with a tag' do
      let(:attrs) { [%w[Tag ru]] }

      it 'returns the tag' do
        expect(record.code).to eq('ru')
      end
    end

    context 'with a tag and a subtag' do
      let(:attrs) { [%w[Tag ru], %w[Subtag zh]] }

      it 'returns the subtag' do
        expect(record.code).to eq('zh')
      end
    end
  end

  describe '#initialize' do
    context 'with attrs containing known fields' do
      let(:attrs) { [%w[File-Date 2023-11-08]] }

      it 'returns a record instance a file_date' do
        expect(record).to be_a(described_class)
        expect(record.file_date).to eq(Date.parse('2023-11-08'))
      end
    end

    context 'with attrs containing unknown fields' do
      let(:attrs) { [['Other-Field', 'A wholly different value']] }

      it 'returns an empty record' do
        expect(record).to be_a(described_class)
        expect(record).to be_empty
      end
    end

    context 'with empty array' do
      let(:attrs) { [[]] }

      it 'returns an empty record' do
        expect(record).to be_a(described_class)
        expect(record).to be_empty
      end
    end
  end
end
