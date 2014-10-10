# SUL-Embed

An [oEmbed](http://oembed.com/) provider for embedding resources from the Stanford University Library.

## Development/Test Sandbox

There is an embedded static page available at `/pages/sandbox` in your development and test environments. Make sure that you use the same host on the service input (first text field) as you are accessing the site from (e.g. localhost or 127.0.0.1).

## oEmbed specification details

URL scheme: `http://purl.stanford.edu/*`

API endpoint: `TBD`

Example: `TBD?url=http://purl.stanford.edu/zw200wd8767&format=json`

## Creating Viewers

You can create a viewer by implementing a class with a pretty simple API.

The viewer class will be instantiated with an Embed::Request object. The `initialize` method is included in the `CommonViewer` mixin but can be overridden

    module Embed
      class DemoViewer
        include Embed::Viewer::CommonViewer
        
      end
    end

The class must implement a `#body_html` method which will be called on the instance of the viewer class. The results of this method combined with `header_html` and `body_html` from `CommonViewer` and will be returned as the HTML of the oEmbed response object.

    module Embed
      class DemoViewer
        include Embed::Viewer::CommonViewer
        
        def body_html
          "<p>#{@purl_object.type}</p>"
        end
      end
    end


The class must define a class method returning an array of which types it will support.  These types are derived from the type attribute from the contentMetadata.

    module Embed
      class DemoViewer
        include Embed::Viewer::CommonViewer

        def body_html
          "<p>#{@purl_object.type}</p>"
        end
        def self.supported_types
          [:demo_type]
        end
      end
    end


The file that the class is defined in (or your preferred method) should register itself as a view with the Embed module.

    module Embed
      class DemoViewer
        include Embed::Viewer::CommonViewer
        
        def body_html
          "<p>#{@purl_object.type}</p>"
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
    $ request = Embed::Request.new({url: 'http://purl.stanford.edu/bb112fp0199'})
    => #<Embed::Request>
    $ viewer.new(request).to_html
    => # your body_html with header and footer html
