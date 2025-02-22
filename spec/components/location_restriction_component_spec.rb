# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocationRestrictionComponent, type: :component do
  before do
    allow(I18n).to receive('t').and_return("Access is restricted to the #{Settings.locations.spec}")
    render_inline(described_class.new('spec'))
  end

  it 'renders the location access restriction message' do
    expect(page).to have_content 'Access is restricted to the Special Collections reading room'
  end
end
