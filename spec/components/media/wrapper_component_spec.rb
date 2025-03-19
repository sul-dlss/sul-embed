# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Media::WrapperComponent, type: :component do
  subject(:render) do
    render_inline(
      described_class.new(
        file:, type:, resource_index:, thumbnail:, size:
      )
    ) do
      'content'
    end
  end

  let(:resource_index) { 0 }
  let(:thumbnail) { '' }
  let(:type) { 'audio' }
  let(:size) { 10 }

  before do
    render
  end

  describe 'data-default-icon attribute' do
    let(:file) { instance_double(Embed::Purl::ResourceFile, stanford_only?: false, location_restricted?: false, view_location_restricted?: false, label_or_filename: 'ignored') }

    context 'with audio' do
      it 'renders the page' do
        expect(page).to have_css('[data-default-icon="audio-thumbnail-icon"]')
        expect(page).to have_css('button[aria-label="Previous item"][disabled]')
        expect(page).to have_css('button[aria-label="Next item"]')
        expect(page).to have_no_css('button[aria-label="Next item"][disabled]')
      end
    end

    context 'with video' do
      let(:type) { 'video' }

      it 'renders the page' do
        expect(page).to have_css('[data-default-icon="video-thumbnail-icon"]')
        expect(page).to have_css('button[aria-label="Previous item"][disabled]')
        expect(page).to have_css('button[aria-label="Next item"]')
        expect(page).to have_no_css('button[aria-label="Next item"][disabled]')
      end
    end
  end

  describe 'data-stanford-only attribute' do
    context 'with Stanford only files' do
      let(:file) { instance_double(Embed::Purl::ResourceFile, stanford_only?: true, location_restricted?: false, view_location_restricted?: false, label_or_filename: 'ignored') }

      it 'renders the page' do
        expect(page).to have_css('[data-stanford-only="true"]')
        expect(page).to have_css('button[aria-label="Previous item"][disabled]')
        expect(page).to have_css('button[aria-label="Next item"]')
        expect(page).to have_no_css('button[aria-label="Next item"][disabled]')
      end
    end

    context 'with public files' do
      let(:file) { instance_double(Embed::Purl::ResourceFile, stanford_only?: false, location_restricted?: false, view_location_restricted?: false, label_or_filename: 'ignored') }

      it 'renders the page' do
        expect(page).to have_css('[data-stanford-only="false"]')
        expect(page).to have_css('button[aria-label="Previous item"][disabled]')
        expect(page).to have_css('button[aria-label="Next item"]')
        expect(page).to have_no_css('button[aria-label="Next item"][disabled]')
      end
    end
  end

  describe 'data-location-restricted attribute' do
    context 'when download and view location restricted' do
      let(:file) { instance_double(Embed::Purl::ResourceFile, stanford_only?: false, location_restricted?: true, view_location_restricted?: true, label_or_filename: 'ignored') }

      it 'renders the page' do
        expect(page).to have_css('[data-location-restricted="true"]')
        expect(page).to have_css('button[aria-label="Previous item"][disabled]')
        expect(page).to have_css('button[aria-label="Next item"]')
        expect(page).to have_no_css('button[aria-label="Next item"][disabled]')
      end
    end

    context 'when only view location restricted' do
      let(:file) { instance_double(Embed::Purl::ResourceFile, stanford_only?: false, location_restricted?: false, view_location_restricted?: true, label_or_filename: 'ignored') }

      it 'renders the page' do
        expect(page).to have_css('[data-location-restricted="true"]')
        expect(page).to have_css('button[aria-label="Previous item"][disabled]')
        expect(page).to have_css('button[aria-label="Next item"]')
        expect(page).to have_no_css('button[aria-label="Next item"][disabled]')
      end
    end

    context 'when not location restricted' do
      let(:file) { instance_double(Embed::Purl::ResourceFile, stanford_only?: true, location_restricted?: false, view_location_restricted?: false, label_or_filename: 'ignored') }

      it 'renders the page' do
        expect(page).to have_css('[data-location-restricted="false"]')
        expect(page).to have_css('button[aria-label="Previous item"][disabled]')
        expect(page).to have_css('button[aria-label="Next item"]')
        expect(page).to have_no_css('button[aria-label="Next item"][disabled]')
      end

      context 'when there is only one item' do
        let(:size) { 1 }

        it 'has both buttons disabled' do
          expect(page).to have_css('button[aria-label="Previous item"][disabled]')
          expect(page).to have_css('button[aria-label="Next item"][disabled]')
        end
      end
    end
  end
end
