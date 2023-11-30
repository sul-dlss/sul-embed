# frozen_string_literal: true

FactoryBot.define do
  factory :purl, class: 'Embed::Purl' do
    druid { 'abc123' }
    contents { [build(:resource, :file)] }
    collections { [] }

    trait :embargoed do
      embargoed { true }
      embargo_release_date { '2053-12-21' }
    end

    trait :embargoed_stanford do
      embargoed
      stanford_only_unrestricted { true }
    end

    trait :file do
      type { 'file' }
      contents { [build(:resource, :file)] }
    end

    trait :was_seed do
      type { 'was-seed' }
      archived_site_url { 'https://swap.stanford.edu/*/http://naca.central.cranfield.ac.uk/' }
      external_url { 'https://swap.stanford.edu/*/http://naca.central.cranfield.ac.uk/' }
      contents { [build(:resource, :image)] }
    end

    trait :geo do
      druid { 'cz128vq0535' }
      type { 'geo' }
      bounding_box { [['-1.478794', '29.572742'], ['4.234077', '35.000308']] }
      public { true }
      contents { [build(:resource, :file, files: [build(:resource_file, filename: 'data.zip'), build(:resource_file, filename: 'data_EPSG_4326.zip')]), build(:resource, :image)] }
    end

    trait :video do
      type { 'media' }
      contents { [build(:resource, :video)] }
    end
  end
end
