module Embed
  module RestrictedText
    private

    def restrictions_text_for_file(file)
      Deprecation.warn(self, 'restrictions_text_for_file is deprecated')

      return unless file.location_restricted? || file.stanford_only?
      <<-HTML.strip_heredoc
        <span class='sul-embed-location-restricted-text #{('sul-embed-stanford-only-text' if file.stanford_only?)}'>
          #{stanford_only_restricted_text(file)}
          #{'(Restricted)' if file.location_restricted?}
        </span>
      HTML
    end

    def stanford_only_restricted_text(file)
      Deprecation.warn(self, 'stanford_only_restricted_text is deprecated')

      return unless file.stanford_only?
      '<span class="sul-embed-text-hide"> Stanford only </span>'
    end
  end
end
