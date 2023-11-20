# frozen_string_literal: true

FactoryBot.define do
  factory :resource, class: 'Embed::Purl::Resource' do
    druid { 'abc123' }

    trait :file do
      type { 'file' }
      description { 'File1 Label' }
    end

    trait :video do
      type { 'video' }
      description { 'First Video' }
      files { [build(:resource_file, :video), build(:resource_file, :vtt), build(:resource_file, :image, filename: 'video_1.jp2')] }
    end

    trait :audio do
      type { 'audio' }
      description { 'First Audio' }
      files { [build(:resource_file, :audio), build(:resource_file, :vtt), build(:resource_file, :image, filename: 'audio_1.jp2')] }
    end

    trait :image do
      type { 'image' }
      description { 'Image of media (1 of 1)' }
      files { [build(:resource_file, :image)] }
    end
  end
end
