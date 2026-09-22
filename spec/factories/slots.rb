# frozen_string_literal: true

FactoryBot.define do
  # Media::Slot is a Data object, so it has to be built rather than assigned attribute by attribute
  factory :slot, class: 'Media::Slot' do
    initialize_with { Media::Slot.new(**attributes) }

    file { association :media_file, :video, :world_downloadable, strategy: :build }
    type { 'video' }
    file_uri { 'https://stacks.stanford.edu/file/bc123df4567/abc_123.mp4' }
    thumbnail { nil }
    index { 0 }
    size { 1 }
    selected { true }

    trait :pdf do
      file { association :media_file, :pdf, :world_downloadable, strategy: :build }
      type { 'file' }
      file_uri { 'https://stacks.stanford.edu/file/bc123df4567/program_notes.pdf' }
    end
  end
end
