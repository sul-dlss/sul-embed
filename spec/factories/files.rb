# frozen_string_literal: true

FactoryBot.define do
  factory :resource_file, class: 'Embed::Purl::ResourceFile' do
    druid { 'bc123df4567' }
    filename { 'data.zip' }
    size { 0 }

    trait :document do
      mimetype { 'application/pdf' }
      filename { 'Title of the PDF.pdf' }
      size { 12_345 }
    end

    trait :hierarchical_file do
      mimetype { 'application/pdf' }
      filename { 'dir1/dir2/Title_of_2_PDF.pdf' }
      size { 12_345 }
    end

    trait :transcript do
      mimetype { 'application/pdf' }
      filename { 'abc_123_transcript.pdf' }
      label { 'PDF transcript label' }
      size { 176_218 }
      role { 'transcription' }
    end

    trait :image do
      mimetype { 'image/jp2' }
      filename { 'image_001.jp2' }
      size { 12_345 }
    end

    trait :model_3d do
      druid { 'qf794pv6287' }
      mimetype { 'model/gltf-binary' }
      filename { 'abc_123.glb' }
      size { 176_218 }
      world_downloadable
    end
  end

  factory :media_file, class: 'Embed::Purl::MediaFile' do
    druid { 'bc123df4567' }
    filename { 'data.zip' }
    size { 0 }

    trait :image do
      mimetype { 'image/jp2' }
      filename { 'image_001.jp2' }
      size { 12_345 }
    end

    trait :video do
      mimetype { 'video/mp4' }
      label { 'First Video' }
      filename { 'abc_123.mp4' }
      size { 152_000_000 }
    end

    trait :audio do
      mimetype { 'audio/mpeg' }
      label { 'First Audio' }
      filename { 'audio.mp3' }
      size { 152_000_000 }
    end

    trait :caption do
      mimetype { 'text/vtt' }
      filename { 'abc_123_cap.vtt' }
      language { 'en' }
      size { 176_218 }
      role { 'caption' }
    end

    trait :autogenerated_media_transcript do
      mimetype { 'text/vtt' }
      filename { 'abc_123_cap.vtt' }
      language { 'en' }
      sdr_generated { true }
      size { 176_218 }
      role { 'caption' }
    end

    trait :media_transcript do
      mimetype { 'text/txt' }
      filename { 'abc_123_cap.txt' }
      language { 'en' }
      size { 176_218 }
      role { 'transcription' }
    end

    trait :model_3d do
      druid { 'qf794pv6287' }
      mimetype { 'model/gltf-binary' }
      filename { 'abc_123.glb' }
      size { 176_218 }
      world_downloadable
    end
  end

  trait :stanford_only do
    view { 'stanford' }
    download { 'stanford' }
  end

  trait :world_downloadable do
    download { 'world' }
  end

  trait :no_download do
    download { 'none' }
  end

  trait :location_restricted do
    download { 'location-based' }
  end

  trait :view_location_restricted do
    view { 'location-based' }
  end
end
