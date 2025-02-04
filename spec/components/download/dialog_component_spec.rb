# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Download::DialogComponent, type: :component do
  subject(:component) { described_class.new }

  before do
    render_inline(component) do
      'Stuff'
    end
  end

  it 'has a content block' do
    expect(page).to have_content 'Download'
    expect(page).to have_content 'Stuff'
  end
end
