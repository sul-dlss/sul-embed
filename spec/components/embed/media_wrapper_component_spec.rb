# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Embed::MediaWrapperComponent, type: :component do
  subject(:render) do
    render_inline(
      described_class.new(
        file:, type:, file_index:, thumbnail:
      )
    )
  end

  let(:file_index) { 0 }
  let(:thumbnail) { '' }
  let(:type) { 'audio' }

  before do
    render
  end

  describe 'data-default-icon attribute' do
    let(:file) { instance_double(Embed::Purl::ResourceFile, stanford_only?: false, location_restricted?: false, label_or_filename: 'ignored', duration: nil) }

    context 'with audio' do
      it 'renders the page' do
        expect(page).to have_css('[data-default-icon="sul-i-file-music-1"]')
      end
    end

    context 'with video' do
      let(:type) { 'video' }

      it 'renders the page' do
        expect(page).to have_css('[data-default-icon="sul-i-file-video-3"]')
      end
    end
  end

  describe 'data-stanford-only attribute' do
    context 'with Stanford only files' do
      let(:file) { instance_double(Embed::Purl::ResourceFile, stanford_only?: true, location_restricted?: false, label_or_filename: 'ignored', duration: nil) }

      it 'renders the page' do
        expect(page).to have_css('[data-stanford-only="true"]')
      end
    end

    context 'with public files' do
      let(:file) { instance_double(Embed::Purl::ResourceFile, stanford_only?: false, location_restricted?: false, label_or_filename: 'ignored', duration: nil) }

      it 'renders the page' do
        expect(page).to have_css('[data-stanford-only="false"]')
      end
    end
  end

  describe 'duration' do
    context 'when the resource file has duration' do
      let(:file) { instance_double(Embed::Purl::ResourceFile, stanford_only?: false, location_restricted?: false, label_or_filename: 'ignored', duration: '1:02') }

      it 'renders the page' do
        expect(page).to have_css('[data-duration="1:02"]')
      end
    end

    context 'when the resource file is missing duration' do
      let(:file) { instance_double(Embed::Purl::ResourceFile, stanford_only?: true, location_restricted?: false, label_or_filename: 'ignored', duration: nil) }

      it 'renders the page' do
        expect(page).not_to have_css('[data-duration]')
      end
    end
  end

  describe 'data-location-restricted attribute' do
    context 'when location restricted' do
      let(:file) { instance_double(Embed::Purl::ResourceFile, stanford_only?: false, location_restricted?: true, label_or_filename: 'ignored', duration: nil) }

      it 'renders the page' do
        expect(page).to have_css('[data-location-restricted="true"]')
      end
    end

    context 'when not location restricted' do
      let(:file) { instance_double(Embed::Purl::ResourceFile, stanford_only?: true, location_restricted?: false, label_or_filename: 'ignored', duration: nil) }

      it 'renders the page' do
        expect(page).to have_css('[data-location-restricted="false"]')
      end
    end
  end
end
