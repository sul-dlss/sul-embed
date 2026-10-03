# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Media::PdfComponent, type: :component do
  subject(:render) do
    render_inline(described_class.new(slot:, page:))
  end

  let(:slot) { build(:slot, :pdf, index:, size: 2, selected:, thumbnail:) }
  let(:index) { 0 }
  let(:selected) { true }
  let(:thumbnail) { nil }
  # NOTE: `page` shadows Capybara's helper here, so these examples assert on rendered_content
  let(:page) { nil }
  let(:pdf_url) { 'https://stacks.stanford.edu/file/bc123df4567/program_notes.pdf' }

  before do
    render
  end

  it 'renders a container for the built in PDF viewer' do
    expect(rendered_content).to have_css('.sul-embed-pdf[data-controller="pdf"]')
  end

  it 'declares which file it is responsible for, so it ignores auth events for its siblings' do
    expect(rendered_content).to have_css(%(.sul-embed-pdf[data-pdf-uri-value="#{pdf_url}"]))
  end

  it 'renders the PDF once the file has been authorized' do
    expect(rendered_content).to have_css('.sul-embed-pdf[data-action*="auth-success@window->pdf#show"]')
  end

  it 'parses the IIIF manifest so the file can be authorized' do
    expect(rendered_content).to have_css('.sul-embed-pdf[data-action*="iiif-manifest-received@window->file-auth#parseFiles"]')
  end

  it 'does not ask for a page when none was requested' do
    expect(rendered_content).to have_no_css('.sul-embed-pdf[data-pdf-page-value]')
  end

  it 'uses the PDF icon in the content list' do
    expect(rendered_content).to have_css('[data-default-icon="pdf-thumbnail-icon"]')
  end

  it 'uses the unmodified file URL for the content list, so it matches the IIIF manifest' do
    expect(rendered_content).to have_css(%([data-media-wrapper-index-value="0"][data-file-uri="#{pdf_url}"]))
  end

  context 'when a page was requested' do
    let(:page) { 4 }

    it 'passes it to the PDF viewer' do
      expect(rendered_content).to have_css('.sul-embed-pdf[data-pdf-page-value="4"]')
    end
  end

  context 'when the viewer opens on a different resource' do
    let(:index) { 1 }
    let(:selected) { false }

    it 'is hidden until its thumbnail is clicked' do
      expect(rendered_content).to have_css('[data-media-wrapper-index-value="1"][hidden]', visible: :all)
    end
  end

  context 'when the resource has a thumbnail' do
    let(:thumbnail) { 'https://stacks.stanford.edu/image/iiif/bc123df4567%2Fpdf_1/square/74,73/0/default.jpg' }

    it 'uses it in the content list rather than the PDF icon' do
      expect(rendered_content).to have_css(%([data-thumbnail-url="#{thumbnail}"]))
    end
  end
end
