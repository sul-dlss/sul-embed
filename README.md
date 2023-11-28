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

To debug, add one or more `debugger` statements to Ruby source code and then attach the debug client:

    bin/rdbg -A

Now visit this URL in your browser!

    http://localhost:3000/pages/sandbox

**NOTE**: If you're doing development on the media player, the above link may get you little more than CORS errors, in which case you likely want to develop against ViewComponent previews:

    http://localhost:3000/rails/view_components/

When developing viewers it can sometimes be helpful to load items using files served from the local development server instead of deployed PURL and Stacks servers. To do this you will want to create a `config/settings.local.yml` file with the following contents:

```yaml
purl_url: 'http://localhost:3000/'
stacks_url: 'http://localhost:3000/'
```

Then you will need to place the "public XML" metadata for an object in the `public` directory `public/{druid}.xml` and the items stacks files in a directory `public/file/druid:{druid}`. For example, for a druid `bk914zc7842` you would have a `public` directory structure that looks something like:

```
public
├── bk914zc7842.xml
└── file
    └── druid:bk914zc7842
        ├── bk914zc7842_low.glb
        ├── bk914zc7842_low.mtl
        ├── bk914zc7842_low.obj
        └── bk914zc7842_normal_low.jpg
```

# Notes for developers

## oEmbed specification details

URL scheme: `https://purl.stanford.edu/*`

API endpoint: `https://embed.stanford.edu`

Example: `https://embed.stanford.edu/embed.json?url=http://purl.stanford.edu/zw200wd8767`


## Linking in viewers

The rich HTML payload that is supplied via the oEmbed API is an iframe. This means that all consumers will be embedding an iframe into their page. Given this fact, generating links will require explicit targets if they are not intended to internally replace embed content.  Given this, there are two patterns that can be used.  For links intended to download files, a `target="_blank"` can be used (effectively opening a new tab for the download which is immediately closed).  When using `target="_blank"` add `rel="noopener noreferrer"` **particularly** when linking externally (although this should be reserved for linking to internal resources when possible). See [this blog post](https://www.jitbit.com/alexblog/256-targetblank---the-most-underestimated-vulnerability-ever/) for an explanation. *Note: This does not apply to WebAuth links.*

For links that are intended to navigate the users browser away from the current page (e.g. the links to Memento/GeoBlacklight/etc.) then `target="_parent"` should be used to give the link the default browser behavior. [More about link targets](http://www.w3schools.com/tags/att_a_target.asp).


## Developing the media player locally

In order to do local development we need to circumvent the need for stacks and a media player.  The first can be done by running a local version of stacks via docker.  You can then configure your local app to point at that container via:
```
SETTINGS__STACKS_URL="http://localhost:3001/" bin/dev
```

Then we'll pull some files local so we don't need a media server:
```
mkdir public/stream && curl https://file-examples.com/storage/fe19e15eac6560f8c936c41/2017/04/file_example_MP4_480_1_5MG.mp4 -o public/stream/file_example_MP4_480_1_5MG.mp4
```

and a sample vtt
```
curl https://stacks.stanford.edu/file/druid:gt507vy5436/gt507vy5436_cap.vtt -o public/gt507vy5436_cap.vtt
```​

## Updating language tags

sul-embed uses the IANA language subtag registry to resolve user-provided file language codes (e.g., 'en-US') onto user-friendly labels (e.g., "English"), primarily for captions in the media player. This file lives on the web and changes every so often. We cache this file in `vendor/data/language-subtag-registry`, and it can be updated via `rake update_language_tags`.
