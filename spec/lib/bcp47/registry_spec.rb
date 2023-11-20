# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bcp47::Registry do
  describe '.file_date' do
    it 'returns the registry file’s date' do
      expect(described_class.file_date).to be_a(Date)
    end
  end

  describe '.records' do
    it 'returns the records' do
      expect(described_class.records).to all(be_a(Bcp47::Record))
    end
  end

  it 'returns actual records' do
    expect(described_class['Hant']).to be_a Bcp47::Record
  end

  it 'deals with duplicate entries' do
    expect(described_class['cmn']).to be_an Array
  end

  describe '#[]' do
    it 'returns values from the registry hash' do
      german = described_class['de']
      expect(german).to be_a Bcp47::Record
      expect(german.code).to eq 'de'
      expect(german.description).to eq('German')
    end
  end

  describe 'sanity checks' do
    it 'finds the subtag CS' do
      serbia_and_montenegro = described_class['CS']
      expect(serbia_and_montenegro.type).to eq 'region'
      expect(serbia_and_montenegro.description).to eq('Serbia and Montenegro')
    end

    it 'finds the subtag cs' do
      czech = described_class['cs']
      expect(czech.type).to eq 'language'
      expect(czech.description).to eq('Czech')
    end

    it 'finds the subtag Cyrs' do
      cyrillic_ocs = described_class['Cyrs']
      expect(cyrillic_ocs.type).to eq 'script'
      expect(cyrillic_ocs.description).to eq('Cyrillic (Old Church Slavonic variant)')
    end

    it 'is not buggy' do
      expect(described_class['mo'].scope).to be_nil
    end

    it 'really isn’t buggy' do
      bokmal = described_class['nb']
      expect(bokmal.macrolanguage).to eq 'no'
    end

    it 'parses the added date' do
      bokmal = described_class['nb']
      expect(bokmal.added).to eq Date.new(2005, 10, 16)
    end
  end

  describe '#resolve' do
    it "combines the records' labels" do
      expect(described_class.resolve('en-us')).to eq 'English, United States'
      expect(described_class.resolve('de-1901')).to eq 'German, Traditional German orthography'
      expect(described_class.resolve('el-polyton')).to eq 'Modern Greek (1453-), Polytonic Greek'
      expect(described_class.resolve('mn-cyrl')).to eq 'Mongolian, Cyrillic'
      expect(described_class.resolve('zh-Hant-TW')).to eq 'Chinese, Han (Traditional variant), Taiwan, Province of China'
    end

    it 'behaves well with private entries' do
      expect(described_class.resolve('qbb-Qabc-QY')).to eq('Private use, Private use, Private use')
    end

    it 'returns nil on nonexistent entries' do
      expect(described_class.resolve('foobar')).to be_nil
    end
  end
end
