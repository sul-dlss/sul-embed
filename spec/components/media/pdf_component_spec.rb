# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Media::PdfComponent, type: :component do
  subject(:render) do
    render_inline(
      described_class.new(file:, type: 'file', resource_index:, thumbnail:, size: 2)
    )
  end

  let(:file) { build(:media_file, :pdf, :world_downloadable) }
  let(:resource_index) { 0 }
  let(:thumbnail) { nil }

  before do
    render
  end

  it 'renders a container for the built in PDF viewer' do
    expect(page).to have_css('.sul-embed-pdf[data-controller="pdf"]')
  end

  it 'declares which file it is responsible for, so it ignores auth events for its siblings' do
    expect(page).to have_css('.sul-embed-pdf[data-pdf-uri-value="https://stacks.stanford.edu/file/bc123df4567/program_notes.pdf"]')
  end

  it 'renders the PDF once the file has been authorized' do
    expect(page).to have_css('.sul-embed-pdf[data-action*="auth-success@window->pdf#show"]')
  end

  it 'parses the IIIF manifest so the file can be authorized' do
    expect(page).to have_css('.sul-embed-pdf[data-action*="iiif-manifest-received@window->file-auth#parseFiles"]')
  end

  it 'is visible because it is the first resource' do
    expect(page).to have_no_css('[data-media-wrapper-index-value="0"][hidden]', visible: :all)
  end

  it 'uses the PDF icon in the content list' do
    expect(page).to have_css('[data-default-icon="pdf-thumbnail-icon"]')
  end

  it 'uses the unmodified file URL for the content list, so it matches the IIIF manifest' do
    object = page.find('[data-media-wrapper-index-value="0"]')
    expect(object['data-file-uri']).to eq 'https://stacks.stanford.edu/file/bc123df4567/program_notes.pdf'
  end

  context 'when it is not the first resource' do
    let(:resource_index) { 1 }

    it 'is hidden until its thumbnail is clicked' do
      expect(page).to have_css('[data-media-wrapper-index-value="1"][hidden]', visible: :all)
    end
  end

  context 'when the resource has a thumbnail' do
    let(:thumbnail) { 'https://stacks.stanford.edu/image/iiif/bc123df4567%2Fpdf_1/square/74,73/0/default.jpg' }

    it 'uses it in the content list rather than the PDF icon' do
      object = page.find('[data-media-wrapper-index-value="0"]')
      expect(object['data-thumbnail-url']).to eq thumbnail
    end
  end
end
