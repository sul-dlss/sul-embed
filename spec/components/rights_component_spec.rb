# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RightsComponent, type: :component do
  before do
    render_inline(described_class.new(viewer:))
  end

  let(:viewer) { instance_double(Embed::Viewer::Media, purl_object:) }
  let(:purl_object) do
    instance_double(Embed::Purl,
                    use_and_reproduction: 'The materials are open for research use',
                    copyright: 'The Board of Trustees of the Leland Stanford Junior University',
                    license: 'cc-0')
  end

  it 'renders something useful' do
    expect(page).to have_content 'The materials are open for research use'
    expect(page).to have_content 'cc-0'
    expect(page).to have_content 'The Board of Trustees of the Leland Stanford Junior University'
  end
end
