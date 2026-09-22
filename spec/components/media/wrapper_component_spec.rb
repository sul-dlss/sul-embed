# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Media::WrapperComponent, type: :component do
  subject(:render) do
    render_inline(described_class.new(slot:)) { 'content' }
  end

  let(:slot) { build(:slot, file:, type:, index:, size:, selected:) }
  let(:file) { build(:media_file, :audio, :world_downloadable) }
  let(:type) { 'audio' }
  let(:index) { 0 }
  let(:size) { 10 }
  let(:selected) { true }

  before do
    render
  end

  describe 'data-default-icon attribute' do
    context 'with audio' do
      it 'renders the page' do
        expect(page).to have_css('[data-default-icon="audio-thumbnail-icon"]')
        expect(page).to have_css('button[aria-label="Previous item"][disabled]')
        expect(page).to have_css('button[aria-label="Next item"]')
        expect(page).to have_no_css('button[aria-label="Next item"][disabled]')
      end
    end

    context 'with video' do
      let(:file) { build(:media_file, :video, :world_downloadable) }
      let(:type) { 'video' }

      it 'renders the page' do
        expect(page).to have_css('[data-default-icon="video-thumbnail-icon"]')
        expect(page).to have_css('button[aria-label="Previous item"][disabled]')
        expect(page).to have_css('button[aria-label="Next item"]')
        expect(page).to have_no_css('button[aria-label="Next item"][disabled]')
      end
    end

    context 'with a PDF' do
      let(:file) { build(:media_file, :pdf, :world_downloadable) }
      let(:type) { 'file' }

      it 'renders the page' do
        expect(page).to have_css('[data-default-icon="pdf-thumbnail-icon"]')
      end
    end
  end

  describe 'data-stanford-only attribute' do
    context 'with Stanford only files' do
      let(:file) { build(:media_file, :audio, :stanford_only) }

      it 'renders the page' do
        expect(page).to have_css('[data-stanford-only="true"]')
      end
    end

    context 'with public files' do
      it 'renders the page' do
        expect(page).to have_css('[data-stanford-only="false"]')
      end
    end
  end

  describe 'data-location-restricted attribute' do
    context 'when view location restricted' do
      let(:file) { build(:media_file, :audio, :view_location_restricted) }

      it 'renders the page' do
        expect(page).to have_css('[data-location-restricted="true"]')
      end
    end

    context 'when not location restricted' do
      it 'renders the page' do
        expect(page).to have_css('[data-location-restricted="false"]')
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

  describe 'the resource the viewer opens on' do
    it 'is visible and marked selected for the content list' do
      expect(page).to have_no_css('[data-media-wrapper-index-value="0"][hidden]', visible: :all)
      expect(page).to have_css('[data-selected="true"]')
    end

    context 'when another resource was selected' do
      let(:selected) { false }
      let(:index) { 2 }

      it 'is hidden and not marked selected' do
        expect(page).to have_css('[data-media-wrapper-index-value="2"][hidden]', visible: :all)
        expect(page).to have_css('[data-selected="false"]', visible: :all)
      end
    end
  end
end
