# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocationRestrictionComponent, type: :component do
  before do
    render_inline(described_class.new)
  end

  # The location restriction banner is hidden so search with visible: :all
  it 'renders banner target for the file auth controller' do
    expect(page).to have_css('div[data-iiif-auth-restriction-target="locationRestriction"]', visible: :all)
  end

  it 'renders message target for the file auth controller' do
    expect(page).to have_css('p[data-iiif-auth-restriction-target="locationRestrictionMessage"]', visible: :all)
  end
end
