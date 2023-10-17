# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DownloadPanelComponent, type: :component do
  before do
    render_inline(described_class.new(title: 'The Panel Title')) { 'Added Panel Content' }
  end

  it 'renders the panel' do
    expect(page).to have_css(
      '.sul-embed-panel-header .sul-embed-panel-title',
      text: 'The Panel Title',
      visible: :all
    )

    expect(page).to have_content('Added Panel Content')
  end
end
