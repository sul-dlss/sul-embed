# frozen_string_literal: true

module Media
  # Displays a PDF (e.g. program notes accompanying a recording) belonging to a media
  # resource using the browser's built-in PDF viewer, the same way the Document viewer does.
  class PdfComponent < ViewComponent::Base
    # @param [Media::Slot] slot the resource this component draws
    # @param [Integer, nil] page the one-based page to open the PDF to
    def initialize(slot:, page: nil)
      @slot = slot
      @page = page
    end

    attr_reader :slot, :page

    delegate :file_uri, :index, to: :slot

    def call
      render WrapperComponent.new(slot:) do
        tag.div(class: 'sul-embed-pdf', data: pdf_data)
      end
    end

    def pdf_data
      { controller: 'pdf', pdf_uri_value: file_uri,
        index:,
        action: 'iiif-manifest-received@window->file-auth#parseFiles ' \
                'auth-success@window->pdf#show' }.tap do |data|
        data[:pdf_page_value] = page if page
      end
    end
  end
end
