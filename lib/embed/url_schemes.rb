module URLSchemes
  def url_schemes
    [Regexp.new(Settings.valid_purl_url)]
  end
end
