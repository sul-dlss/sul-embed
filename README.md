[![CI](https://github.com/sul-dlss/sul-embed/actions/workflows/ruby.yml/badge.svg)](https://github.com/sul-dlss/sul-embed/actions/workflows/ruby.yml)

# SUL-Embed

An [oEmbed](http://oembed.com/) provider for embedding resources from the Stanford University Library.

## Development/Test Sandbox

There is an embedded static page available at `/pages/sandbox` in your development and test environments. Make sure that you use the same host on the service input (first text field) as you are accessing the site from (e.g. localhost or 127.0.0.1).

To bring up a dev environment first you'll need to install Ruby and JavaScript dependencies. Note: NodeJS v18 and [yarn](https://yarnpkg.com/) must be installed:

    bundle install
    yarn install

Then start up the Rails app (web server, debugger, CSS bundler, JS bundler) in one terminal window:

    bin/dev

To debug, add one or more `debugger` statements to Ruby source code and then attach the debug clientr:

    bundle exec rdbg -A

Now visit this URL in your browser!

    http://localhost:3000/pages/sandbox

# Notes for developers

## oEmbed specification details

URL scheme: `https://purl.stanford.edu/*`

API endpoint: `https://embed.stanford.edu`

Example: `https://embed.stanford.edu/embed.json?url=http://purl.stanford.edu/zw200wd8767`

## Creating Viewers

You can create a viewer by implementing a class with a pretty simple API.

The viewer class will be instantiated with an Embed::Request object. The `initialize` method is included in the `CommonViewer` parent class but can be overridden.

    module Embed
      class Viewer
        class DemoViewer < CommonViewer
        end
      end
    end


The class must define a class method returning an array of which types it will support.  These types are derived from the type attribute from the contentMetadata.

    module Embed
      class Viewer
        class DemoViewer < CommonViewer

          def self.supported_types
            [:demo_type]
          end
        end
      end
    end


The file that the class is defined in (or your preferred method) should register itself as a view with the Embed module.

    module Embed
      class Viewer
        class DemoViewer < CommonViewer
          def self.supported_types
            [:demo_type]
          end
        end
      end
    end

    Embed.register_viewer(Embed::Viewer::DemoViewer) if Embed.respond_to?(:register_viewer)

## SDR data models and their specifications

See https://consul.stanford.edu/display/SDRdocs/Content+types+and+resource+types+in+SDR

### Linking in viewers

The rich HTML payload that is supplied via the oEmbed API is an iframe. This means that all consumers will be embedding an iframe into their page. Given this fact, generating links will require explicit targets if they are not intended to internally replace embed content.  Given this, there are two patterns that can be used.  For links intended to download files, a `target="_blank"` can be used (effectively opening a new tab for the download which is immediately closed).  When using `target="_blank"` add `rel="noopener noreferrer"` **particularly** when linking externally (although this should be reserved for linking to internal resources when possible). See [this blog post](https://www.jitbit.com/alexblog/256-targetblank---the-most-underestimated-vulnerability-ever/) for an explanation. *Note: This does not apply to WebAuth links.*

For links that are intended to navigate the users browser away from the current page (e.g. the links to Memento/GeoBlacklight/etc.) then `target="_parent"` should be used to give the link the default browser behavior. [More about link targets](http://www.w3schools.com/tags/att_a_target.asp).

### Console Example

    $ viewer = Embed.registered_viewers.first
    => Embed::DemoViewer
    $ request = Embed::Request.new({url: 'http://purl.stanford.edu/bb112fp0199'})
    => #<Embed::Request>
    $ viewer.new(request)
    => # your viewer instance


### Customizing the Embed Panel

Viewers can customize the embed panel.  To do this, create a template in `app/views/embed/embed-this`, to provide the HTML for the embed panel.

See File viewers for an example.


### Adding a Download Panel
Viewers can add their own download panel.  To do this, create a component in `app/components/embed/download`, to provide the HTML for the download panel.

In order to enable the download panel you need to provide a method in your viewer class.  This method lets the footer logic know that the viewer will provide a download panel and it should render the Download button.

    def show_download?
      true
    end
