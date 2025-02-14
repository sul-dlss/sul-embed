# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompanionWindows::ControlButtonComponent, type: :component do
  let(:component) { described_class.new(aria: { controls: 'foo', label: 'bar', selected: true }, action: 'baz') }

  before { render_inline(component) }

  it 'renders the button' do
    expect(page).to have_css('button[aria-label="bar"][aria-controls="foo"][aria-selected="true"]' \
                             '[data-action="baz mouseenter->tooltip#show focus->tooltip#show mouseleave->tooltip#hide blur->tooltip#hide"]' \
                             '[data-controller="tooltip"]')
  end

  context 'when data is passed' do
    let(:component) { described_class.new(aria: { label: 'bar' }, action: 'baz', data: { test: 'success' }) }

    it 'adds the data params' do
      expect(page).to have_css('button[aria-label="bar"]' \
                               '[data-action="baz mouseenter->tooltip#show focus->tooltip#show mouseleave->tooltip#hide blur->tooltip#hide"]' \
                               '[data-controller="tooltip"]' \
                               '[data-test="success"]')
    end
  end
end
