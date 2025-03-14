# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RestrictedMessageComponent, type: :component do
  before do
    render_inline(described_class.new)
  end

  # The location restriction banner is hidden so search with visible: :all
  it 'renders banner target for the file auth controller' do
    expect(page).to have_css('div[data-iiif-auth-restriction-target="restrictedContainer"]', visible: :all)
  end

  it 'renders message target for the file auth controller' do
    expect(page).to have_css('p[data-iiif-auth-restriction-target="restrictedMessage"]', visible: :all)
  end
end
