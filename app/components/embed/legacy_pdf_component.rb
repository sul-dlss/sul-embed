# frozen_string_literal: true

# NOTE: When we decide we no longer need the LegacyPdfComponent, this component can be removed, along with:
#  1. The "pdfjs-dist" package in package.json
#  2. The entire app/javascript/src/modules/pdf_viewer.js file
#  3. The entire app/javascript/packs/legacy_pdf_viewer.js file
#  4. The legacy_pdf_viewer feature flag in settings (in this codebase and in shared_configs).
#  5. The reference to the feature flag and LegacyPdfComponent in app/viewers/embed/viewer/pdf_viewer.rb
#  6. The app/stylesheets/pdf.scss file and references to it in package.json
module Embed
  class LegacyPdfComponent < ViewComponent::Base
    def initialize(viewer:)
      @viewer = viewer
    end

    attr_reader :viewer
  end
end
