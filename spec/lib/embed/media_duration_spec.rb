# frozen_string_literal: true

require 'rails_helper'
require 'embed/media_duration'

describe Embed::MediaDuration do
  describe '#to_s' do
    context 'human-readable string for an iso8601 duration string' do
      { # raw value  =>  display value
        'P0DT1H2M3S' => '1:02:03',
        'PT2M3S' => '2:03',
        'PT10S' => '0:10',
        'P5DT1H2M3S' => '5:01:02:03',
        'P9D' => '9:00:00:00'
      }.each do |raw_val, display_val|
        it "'#{display_val}' for '#{raw_val}' in videoData" do
          video_data_el = Nokogiri::XML("<videoData duration='#{raw_val}'/>").root
          expect(described_class.new(video_data_el).to_s).to eq display_val
        end

        it "'#{display_val}' for '#{raw_val}' in audioData" do
          audio_data_el = Nokogiri::XML("<audioData duration='#{raw_val}'/>").root
          expect(described_class.new(audio_data_el).to_s).to eq display_val
        end
      end
    end

    it 'nil and logs error for iso8601 valid but bad media duration string' do
      video_data_el = Nokogiri::XML("<videoData duration='P2W'/>").root
      expect(Honeybadger).to receive(:notify).with('Embed::MediaDuration::ISODuration does not support specifying durations in weeks')
      expect(described_class.new(video_data_el).to_s).to be_nil
      audio_data_el = Nokogiri::XML("<audioData duration='-PT10S'/>").root
      expect(Honeybadger).to receive(:notify).with('Embed::MediaDuration::ISODuration does not support specifying negative durations')
      expect(described_class.new(audio_data_el).to_s).to be_nil
    end

    it 'nil and logs error for invalid iso8601 duration string' do
      audio_data_el = Nokogiri::XML("<audioData duration='invalid'/>").root
      expect(described_class.new(audio_data_el).to_s).to be_nil
    end

    it 'nil if no duration attribute on media__data_element' do
      audio_data_el = Nokogiri::XML('<audioData/>').root
      expect(described_class.new(audio_data_el).to_s).to be_nil
    end

    it 'nil if media__data_element is nil' do
      expect(described_class.new(nil).to_s).to be_nil
    end
  end

  describe '#duration_raw_value' do
    it 'gets value from duration attribute of media__data_element' do
      val = 'PT43S'
      audio_data_el = Nokogiri::XML("<audioData duration='#{val}''/>").root
      expect(described_class.new(audio_data_el).send(:duration_raw_value)).to eq val
    end

    it 'nil if no duration attribute' do
      video_data_el = Nokogiri::XML('<videoData/>').root
      expect(described_class.new(video_data_el).send(:duration_raw_value)).to be_nil
    end

    it 'nil if media__data_element is nil' do
      expect(described_class.new(nil).send(:duration_raw_value)).to be_nil
    end
  end

  context 'ISODuration class' do
    describe '#to_s' do
      { # raw value  =>  display value
        'P0DT1H2M3S' => '1:02:03',
        'PT2M3S' => '2:03',
        'PT10S' => '0:10',
        'P5DT1H2M3S' => '5:01:02:03',
        'P9D' => '9:00:00:00'
      }.each do |raw_val, display_val|
        it "'#{display_val}' for '#{raw_val}' as iso8601 duration string" do
          expect(Embed::MediaDuration::ISODuration.new(raw_val).to_s).to eq display_val
        end
      end
      it 'nil for an unsupported ISODuration specification' do
        d = Embed::MediaDuration::ISODuration.new('P10W')
        expect(d).to receive(:supported_duration?)
        expect(d.to_s).to be_nil
      end
    end

    describe '#supported_duration?' do
      context 'false and logs the appropriate error for' do
        it 'week duration' do
          expect(Honeybadger).to receive(:notify).with('Embed::MediaDuration::ISODuration does not support specifying durations in weeks')
          expect(Embed::MediaDuration::ISODuration.new('P10W').send(:supported_duration?)).to be false
        end

        it 'negative duration' do
          expect(Honeybadger).to receive(:notify).with('Embed::MediaDuration::ISODuration does not support specifying negative durations')
          expect(Embed::MediaDuration::ISODuration.new('-PT10S').send(:supported_duration?)).to be false
        end
      end
    end
  end
end
