# frozen_string_literal: true

require 'rails_helper'

describe Embed::WasTimeMap do
  include WasTimeMapFixtures

  subject { described_class.new('http://wayback.example.com/timemap/http://ennejah.info') }
  describe '#timemap' do
    context 'when HTTP is successful' do
      before do
        expect(Faraday).to receive(:get).and_return(double('response', body: timemap, success?: true))
      end

      it 'requests and parses timemap to an array' do
        expect(subject.timemap.length).to eq 10
        subject.timemap.each do |memento_line|
          expect(memento_line).to be_an(Embed::WasTimeMap::MementoLine)
        end
      end

      it 'the memento lines are not all memento entries' do
        expect(subject.timemap.count(&:memento?)).to eq 7
      end

      it 'memento lines have accessors' do
        memento_line = subject.timemap.find(&:memento?)
        expect(memento_line.url).to eq 'https://swap.stanford.edu/20090718213431/http://ennejah.info/'
        expect(memento_line.rel).to eq 'first memento'
        expect(memento_line.datetime).to eq 'Sat, 18 Jul 2009 21:34:31 GMT'
      end
    end
  end
  context 'when HTTP is not successful' do
    before do
      expect(Faraday).to receive(:get).and_return(double('response', success?: false))
    end

    it 'raises an exception' do
      expect { subject.timemap }.to raise_error Embed::WasTimeMap::ResourceNotAvailable
    end
  end
end
