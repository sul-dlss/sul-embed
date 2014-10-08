# SUL-Embed

An [oEmbed](http://oembed.com/) provider for embedding resources from the Stanford University Library.

## oEmbed specification details

URL scheme: `http://purl.stanford.edu/*`

API endpoint: `TBD`

Example: `TBD?url=http://purl.stanford.edu/zw200wd8767&format=json`

## Creating Viewers

You can create a viewer by implementing a class with a pretty simple API.

The viewer class will be instantiated with an Embed::PURL object.

    module Embed
      class DemoViewer
        def initialize(purl_object)
          @purl_object = purl_object
        end
      end
    end

The class must implement a `#to_html` method which will be called on the instance of the viewer class. The results of this method will be returned as the HTML of the oEmbed response object.

    module Embed
      class DemoViewer
        def initialize(purl_object)
          @purl_object = purl_object
        end
        def to_html
          "<h1>#{@purl_object.title}</h1>"
        end
      end
    end


The class must define a class method returning an array of which types it will support.  These types are derived from the type attribute from the contentMetadata.

    module Embed
      class DemoViewer
        def initialize(purl_object)
          @purl_object = purl_object
        end
        def to_html
          "<h1>#{@purl_object.title}</h1>"
        end
        def self.supported_types
          [:demo_type]
        end
      end
    end


The file that the class is defined in (or your preferred method) should register itself as a view with the Embed module.

    module Embed
      class DemoViewer
        def initialize(purl_object)
          @purl_object = purl_object
        end
        def to_html
          "<h1>#{@purl_object.title}</h1>"
        end
        def self.supported_types
          [:demo_type]
        end
      end
    end
    
    Embed.register_viewer(Embed::DemoViewer) if Embed.respond_to?(:register_viewer)

### Console Example

    $ viewer = Embed.registered_viewers.first
    => Embed::DemoViewer
    $ purl = Embed::PURL.new('bb112fp0199')
    => #<Embed::PURL>
    $ viewer.new(purl).to_html
    => "<h1>Writings - \"How to Test a Good Trumpet,\" The Instrumentalist 31(8):57-58 (reprint, 2 pp.)</h1>"

