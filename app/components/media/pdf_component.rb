# frozen_string_literal: true

module Media
  # Displays a PDF (e.g. program notes accompanying a recording) belonging to a media
  # resource using the browser's built-in PDF viewer, the same way the Document viewer does.
  class PdfComponent < ViewComponent::Base
    # @param [Embed::Purl::MediaFile] file the PDF to display
    # @param [String] type the resource type
    # @param [Integer] resource_index the offset of this resource in the purl
    # @param [String, nil] thumbnail the URL of the resource thumbnail, if it has one
    # @param [Integer] size the number of resources in the purl
    def initialize(file:, type:, resource_index:, thumbnail:, size:)
      @file = file
      @type = type
      @resource_index = resource_index
      @thumbnail = thumbnail
      @size = size
    end

    attr_reader :file, :type, :resource_index, :thumbnail, :size

    def call
      render WrapperComponent.new(file:, type:, resource_index:, thumbnail:, size:) do
        tag.div(class: 'sul-embed-pdf',
                data: { controller: 'pdf', pdf_uri_value: file.file_url,
                        index: resource_index,
                        action: 'iiif-manifest-received@window->file-auth#parseFiles ' \
                                'auth-success@window->pdf#show' })
      end
    end
  end
end
