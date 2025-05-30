# frozen_string_literal: true

FactoryBot.define do
  factory :purl, class: 'Embed::Purl' do
    druid { 'abc123' }
    contents { [build(:resource, :file)] }
    constituents { [] }
    collections { [] }
    etag { "W/\"#{Time.zone.now.to_f}\"" }
    last_modified { Time.zone.now }

    trait :citation_only do
      view { 'citation-only' }
    end

    trait :embargoed do
      embargoed { true }
      embargo_release_date { '2053-12-21' }
    end

    trait :embargoed_stanford do
      embargoed
      download { 'stanford' }
    end

    trait :file do
      type { 'file' }
      title { 'Title of the object' }
      contents { [build(:resource, :file)] }
    end

    trait :document do
      type { 'document' }
      title { 'Title of the object' }
      contents { [build(:resource, :document)] }
    end

    trait :document_no_download do
      type { 'document' }
      title { 'Title of the object' }
      contents { [build(:resource, :document_no_download)] }
    end

    trait :was_seed do
      type { 'webarchive-seed' }
      archived_site_url { 'https://swap.stanford.edu/*/http://naca.central.cranfield.ac.uk/' }
      external_url { 'https://swap.stanford.edu/*/http://naca.central.cranfield.ac.uk/' }
      contents { [build(:resource, :image)] }
    end

    trait :geo do
      druid { 'cz128vq0535' }
      type { 'geo' }
      bounding_box { [['-1.478794', '29.572742'], ['4.234077', '35.000308']] }
      download { 'world' }
      view { 'world' }
      contents { [build(:resource, :file, files: [build(:resource_file, :world_downloadable, :view_world, filename: 'data.zip'), build(:resource_file, :world_downloadable, :view_world, filename: 'data_EPSG_4326.zip')]), build(:resource, :image)] }
    end

    trait :media do
      type { 'media' }
    end

    trait :image do
      type { 'image' }
    end

    trait :video do
      media
      contents { [build(:resource, :video)] }
    end

    trait :model_3d do
      type { '3d' }
      druid { 'qf794pv6287' }
      title { 'Title of the object' }
      contents { [build(:resource, :model_3d, files: [build(:resource_file, :model_3d)])] }
    end
  end
end
