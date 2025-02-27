# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DialogComponent, type: :component do
  subject(:component) { described_class.new(dialog_id: 'this-dialog', stimulus_target: 'thisDialog') }

  before do
    render_inline(component) do
      component.with_header do
        'This Dialog'
      end

      component.with_main do
        '<p>Some information</p>'
      end

      component.with_footer do
        '<button>Close</button>'
      end
    end
  end

  it { expect(page).to have_content 'This Dialog' }
  it { expect(page).to have_content 'Some information' }
  it { expect(page).to have_content 'Close' }
  it { expect(page).to have_css '#this-dialog' }
  it { expect(page).to have_css '#this-dialog-modal-header' }
  it { expect(page).to have_css '[data-companion-window-target="thisDialog"]' }
  it { expect(page).to have_css '[aria-labelledby="this-dialog-modal-header"]' }
  it { expect(page).to have_css '[data-action="click->companion-window#handleBackdropClicks"]' }
end
