# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Document::AuthMessagesComponent, type: :component do
  subject(:component) { described_class.new(message:) }

  before do
    render_inline(component)
  end

  context 'when the message is an embargo message' do
    let(:message) { { type: 'embargo', message: 'Embargo message' } }

    it 'has svg and message' do
      expect(page).to have_css('svg')
      expect(page).to have_content('Embargo message')
    end
  end

  context 'when the message is an location restricted message' do
    let(:message) { { type: 'location-restricted', message: 'Location restricted message' } }

    it 'has svg and message' do
      expect(page).to have_css('svg')
      expect(page).to have_content('Location restricted message')
    end
  end
end
