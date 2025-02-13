# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompanionWindows::ControlButtonComponent, type: :component do
  before { puts render_inline(described_class.new(aria: { controls: 'foo', label: 'bar', selected: true }, action: 'baz')) }

  it 'renders the button' do
    expect(page).to have_css('button[aria-label="bar"][aria-controls="foo"][aria-selected="true"]' \
                             '[data-action="baz mouseenter->tooltip#show focus->tooltip#show mouseleave->tooltip#hide blur->tooltip#hide"]' \
                             '[data-controller="tooltip"]')
  end
end
