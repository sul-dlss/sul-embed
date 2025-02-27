# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompanionWindows::RightsComponent, type: :component do
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

  it 'renders the rights information and an attribution logo' do
    expect(page).to have_content 'The materials are open for research use'
    expect(page).to have_content 'cc-0'
    expect(page).to have_content 'The Board of Trustees of the Leland Stanford Junior University'
    expect(page).to have_no_content 'Provided by the Stanford University Libraries'
    # visible :all because we display:none because this isn't the default tab.
    expect(page).to have_css('img.attributionLogo', visible: :all)
  end

  context 'when object has no rights information' do
    let(:purl_object) do
      instance_double(Embed::Purl,
                      use_and_reproduction: nil,
                      copyright: nil,
                      license: nil)
    end

    it 'renders the default attribution information' do
      expect(page).to have_content 'Provided by the Stanford University Libraries'
    end
  end
end
