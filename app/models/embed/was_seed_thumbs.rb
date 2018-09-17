module Embed
  # WasSeedThumbs class is responsible of reading the thumbnails
  # list retrieved from was-thumbnail service in JSON format.
  # The class should be able to parse and convert the response
  # into hash list
  class WasSeedThumbs
    attr_reader :druid

    # initializes a new object
    # @param druid [String] the druid object in the format "aa111aa1111"
    def initialize(druid)
      @druid = druid
    end

    # retrieves the thumbnail list associated with the seed uri
    # defined by the druid
    # @return [Array] represents the thumnail list
    # @example
    #   Embed::WasSeedThumbs.new('aa111aa1111').thumbs_list
    #    [{'memento_uri'=>'','memento_datetime'=> '','thumbnail_uri'=> 'http...default.jpg'},
    #     {'memento_uri'=> '','memento_datetime'=> '','thumbnail_uri'=> 'http...default.jpg'}]
    def thumbs_list
      raise ResourceNotAvailable if response.nil?

      @thumbs_list ||= begin
        result = JSON.parse(response)
        result['thumbnails']
      end
    end

    # reads the response from the thumbnail service
    # @return [String] response of the request, nil if there is error
    # @raise [ResourceNotAvailable] if there response returns not success
    def response
      @response ||= begin
        conn = Faraday.new(url: was_thumbs_url)
        response = conn.get do |request|
          request.options.timeout = Settings.was_thumb_read_timeout
          request.options.open_timeout = Settings.was_thumb_conn_timeout
          request.params['format'] = 'json'
        end
        raise ResourceNotAvailable unless response.success?

        response.body
      rescue Faraday::Error::ConnectionFailed, Faraday::Error::TimeoutError
        nil
      end
    end

    def was_thumbs_url
      "#{Settings.was_thumbs_url}/#{@druid}"
    end

    class ResourceNotAvailable < StandardError
      def initialize(msg = 'The requested seed thumbnails list was not available')
        super
      end
    end
  end
end
