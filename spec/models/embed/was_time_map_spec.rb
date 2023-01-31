# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::WasTimeMap do
  include WasTimeMapFixtures

  subject { described_class.new('http://wayback.example.com/timemap/http://ennejah.info') }

  describe '#timemap' do
    let(:fake_connection) do
      instance_double(Faraday::Connection, get: instance_double(Faraday::Response, body: timemap, success?: true))
    end

    context 'when HTTP is successful' do
      before do
        allow_any_instance_of(described_class).to receive(:redirectable_connection).and_return(fake_connection)
        expect(fake_connection).to receive(:get).once
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

  describe '#timemap (new behavior)' do
    let(:fake_connection) do
      instance_double(Faraday::Connection, get: instance_double(Faraday::Response, body: timemap_new, success?: true))
    end

    context 'when HTTP is successful' do
      before do
        allow_any_instance_of(described_class).to receive(:redirectable_connection).and_return(fake_connection)
        expect(fake_connection).to receive(:get).once
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
        # NOTE: this needed changing to pass! Problematic?
        expect(memento_line.rel).to eq 'memento'
        expect(memento_line.datetime).to eq 'Sat, 18 Jul 2009 21:34:31 GMT'
      end
    end
  end

  context 'when HTTP is not successful' do
    let(:fake_connection) do
      instance_double(Faraday::Connection, get: instance_double(Faraday::Response, success?: false))
    end

    before do
      allow_any_instance_of(described_class).to receive(:redirectable_connection).and_return(fake_connection)
      expect(fake_connection).to receive(:get).once
    end

    it 'catches the exception and returns an empty array' do
      expect(subject.timemap).to eq []
    end
  end
end
