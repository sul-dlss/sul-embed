# frozen_string_literal: true

FactoryBot.define do
  factory :purl, class: 'Embed::Purl' do
    druid { 'abc123' }
    contents { [build(:resource, :file)] }

    trait :was_seed do
      type { 'was-seed' }
      archived_site_url { 'https://swap.stanford.edu/*/http://naca.central.cranfield.ac.uk/' }
      external_url { 'https://swap.stanford.edu/*/http://naca.central.cranfield.ac.uk/' }
      contents { [build(:resource, :image)] }
    end
  end
end
