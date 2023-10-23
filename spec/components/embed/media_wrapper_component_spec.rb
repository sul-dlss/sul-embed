# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::MediaWrapperComponent, type: :component do
  subject(:render) do
    render_inline(
      described_class.new(
        file:, file_index:, thumbnail:
      )
    )
  end

  let(:file_index) { 0 }
  let(:thumbnail) { '' }

  before do
    render
  end

  describe 'data-stanford-only attribute' do
    context 'with Stanford only files' do
      let(:file) { instance_double(Embed::Purl::ResourceFile, stanford_only?: true, location_restricted?: false, label: 'ignored', duration: nil) }

      it 'renders the page' do
        expect(page).to have_css('[data-stanford-only="true"]')
      end
    end

    context 'with public files' do
      let(:file) { instance_double(Embed::Purl::ResourceFile, stanford_only?: false, location_restricted?: false, label: 'ignored', duration: nil) }

      it 'renders the page' do
        expect(page).to have_css('[data-stanford-only="false"]')
      end
    end
  end

  describe 'duration' do
    context 'when the resource file has duration' do
      let(:file) { instance_double(Embed::Purl::ResourceFile, stanford_only?: false, location_restricted?: false, label: 'ignored', duration: '1:02') }

      it 'renders the page' do
        expect(page).to have_css('[data-duration="1:02"]')
      end
    end

    context 'when the resource file is missing duration' do
      let(:file) { instance_double(Embed::Purl::ResourceFile, stanford_only?: true, location_restricted?: false, label: 'ignored', duration: nil) }

      it 'renders the page' do
        expect(page).not_to have_css('[data-duration]')
      end
    end
  end

  describe 'data-location-restricted attribute' do
    context 'when location restricted' do
      let(:file) { instance_double(Embed::Purl::ResourceFile, stanford_only?: false, location_restricted?: true, label: 'ignored', duration: nil) }

      it 'renders the page' do
        expect(page).to have_css('[data-location-restricted="true"]')
      end
    end

    context 'when not location restricted' do
      let(:file) { instance_double(Embed::Purl::ResourceFile, stanford_only?: true, location_restricted?: false, label: 'ignored', duration: nil) }

      it 'renders the page' do
        expect(page).to have_css('[data-location-restricted="false"]')
      end
    end
  end
end
