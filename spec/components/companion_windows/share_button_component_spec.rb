# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompanionWindows::ShareButtonComponent, type: :component do
  before { render_inline(described_class.new) }

  it 'renders the button' do
    expect(page).to have_css('button[aria-label="Share & download"]')
  end
end
