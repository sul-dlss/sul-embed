module Embed
  class Viewer
    class WasSeed < CommonViewer

      def initialize(*args)
        super
      end

      def body_html
        Nokogiri::HTML::Builder.new do |doc|
          doc.div(class: 'sul-embed-body', 'style' => "max-height: #{body_height}px", 'data-sul-embed-theme' => "#{asset_url('was_seed.css')}") do
            doc.div(class: 'sul-embed-was-seed', 'data-sul-thumbs-list-count'=>thumbs_list.length) do
              doc.ul(class: 'sul-embed-was-thumb-list') do
                thumbs_list.each do |thumb_record|
                  doc.li(class: 'sul-embed-was-thumb-item') do
                    doc.div(class: 'sul-embed-was-thumb-item-div', style: "height: #{item_size[0]}px; width: #{item_size[1]}px;") do
                      doc.img(class: 'sul-embed-was-thumb-item-img', style: "height: #{image_height}px;", src: thumb_record['thumbnail_uri'])
                      doc.div(class: 'sul-embed-was-thumb-item-date') do
                        doc.a(href: thumb_record['memento_uri']) do
                          doc.text(format_memento_datetime(thumb_record['memento_datetime']))
                        end
                      end
                    end
                  end
                end
              end
            end
            doc.script { doc.text ";jQuery.getScript(\"#{asset_url('was_seed.js')}\");" }
          end
        end.to_html
      end

      def self.supported_types
        [:"webarchive-seed"]
      end

      def thumbs_list
        Embed::WasSeedThumbs.new(@purl_object.druid).get_thumbs_list
      end

      def format_memento_datetime(memento_datetime)
        I18n.l(Date.parse(memento_datetime), format: :sul) unless memento_datetime.blank?
      end

      def external_url
        @purl_object.ng_xml.xpath('//dc:identifier','dc'=>'http://purl.org/dc/elements/1.1/').try(:text)
      end

      def external_url_text
        'View this in the Stanford Web Archive Portal'
      end

      def default_body_height
        260
      end

      def item_size
        [body_height - 60, body_height - 60]
      end
      
      def image_height
        item_size[0] - 24
      end
    end
  end
end

Embed.register_viewer(Embed::Viewer::WasSeed) if Embed.respond_to?(:register_viewer)
