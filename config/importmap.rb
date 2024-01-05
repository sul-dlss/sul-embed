# Pin npm packages by running ./bin/importmap

pin "media", preload: true
pin "webarchive", preload: true
pin "file", preload: true
pin "document", preload: true
pin "3d", preload: true

pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/file_controllers", under: "file_controllers"
# pin "modules/embed_this", to: "app/javascript/src/modules/embed_this.js"
pin_all_from 'app/javascript/src', under: 'src', to: 'src'

pin "video.js", to: "https://ga.jspm.io/npm:video.js@8.6.1/dist/video.es.js"
pin "@babel/runtime/helpers/extends", to: "https://ga.jspm.io/npm:@babel/runtime@7.23.5/helpers/esm/extends.js"
pin "@videojs/vhs-utils/es/byte-helpers", to: "https://ga.jspm.io/npm:@videojs/vhs-utils@4.1.0/es/byte-helpers.js"
pin "@videojs/vhs-utils/es/containers", to: "https://ga.jspm.io/npm:@videojs/vhs-utils@4.1.0/es/containers.js"
pin "@videojs/vhs-utils/es/decode-b64-to-uint8-array", to: "https://ga.jspm.io/npm:@videojs/vhs-utils@3.0.5/es/decode-b64-to-uint8-array.js"
pin "@videojs/vhs-utils/es/", to: "https://ga.jspm.io/npm:@videojs/vhs-utils@3.0.5/es/"
pin "@videojs/vhs-utils/es/id3-helpers", to: "https://ga.jspm.io/npm:@videojs/vhs-utils@4.1.0/es/id3-helpers.js"
pin "@videojs/vhs-utils/es/media-groups", to: "https://ga.jspm.io/npm:@videojs/vhs-utils@3.0.5/es/media-groups.js"
pin "@videojs/vhs-utils/es/resolve-url", to: "https://ga.jspm.io/npm:@videojs/vhs-utils@3.0.5/es/resolve-url.js"
pin "@videojs/xhr", to: "https://ga.jspm.io/npm:@videojs/xhr@2.6.0/lib/index.js"
pin "@xmldom/xmldom", to: "https://ga.jspm.io/npm:@xmldom/xmldom@0.8.10/lib/index.js"
pin "dom-walk", to: "https://ga.jspm.io/npm:dom-walk@0.1.2/index.js"
pin "global/document", to: "https://ga.jspm.io/npm:global@4.4.0/document.js"
pin "global/window", to: "https://ga.jspm.io/npm:global@4.4.0/window.js"
pin "is-function", to: "https://ga.jspm.io/npm:is-function@1.0.2/index.js"
pin "keycode", to: "https://ga.jspm.io/npm:keycode@2.2.0/index.js"
pin "m3u8-parser", to: "https://ga.jspm.io/npm:m3u8-parser@6.2.0/dist/m3u8-parser.es.js"
pin "min-document", to: "https://ga.jspm.io/npm:min-document@2.19.0/index.js"
pin "mpd-parser", to: "https://ga.jspm.io/npm:mpd-parser@1.2.2/dist/mpd-parser.es.js"
pin "mux.js/lib/tools/parse-sidx", to: "https://ga.jspm.io/npm:mux.js@7.0.2/lib/tools/parse-sidx.js"
pin "mux.js/lib/utils/clock", to: "https://ga.jspm.io/npm:mux.js@7.0.2/lib/utils/clock.js"
pin "safe-json-parse/tuple", to: "https://ga.jspm.io/npm:safe-json-parse@4.0.0/tuple.js"
pin "url-toolkit", to: "https://ga.jspm.io/npm:url-toolkit@2.2.5/src/url-toolkit.js"
pin "videojs-vtt.js", to: "https://ga.jspm.io/npm:videojs-vtt.js@0.15.5/lib/browser-index.js"
pin "openseadragon", to: "https://ga.jspm.io/npm:openseadragon@4.1.0/build/openseadragon/openseadragon.js"
pin "fscreen", to: "https://ga.jspm.io/npm:fscreen@1.2.0/dist/fscreen.cjs.js"
pin "@google/model-viewer", to: "https://ga.jspm.io/npm:@google/model-viewer@3.3.0/lib/model-viewer.js"
pin "@lit/reactive-element", to: "https://ga.jspm.io/npm:@lit/reactive-element@1.6.3/reactive-element.js"
pin "@lit/reactive-element/decorators/", to: "https://ga.jspm.io/npm:@lit/reactive-element@1.6.3/decorators/"
pin "lit", to: "https://ga.jspm.io/npm:lit@2.8.0/index.js"
pin "lit-element/lit-element.js", to: "https://ga.jspm.io/npm:lit-element@3.3.3/lit-element.js"
pin "lit-html", to: "https://ga.jspm.io/npm:lit-html@2.8.0/lit-html.js"
pin "lit-html/is-server.js", to: "https://ga.jspm.io/npm:lit-html@2.8.0/is-server.js"
pin "lit/decorators.js", to: "https://ga.jspm.io/npm:lit@2.8.0/decorators.js"
pin "three", to: "https://ga.jspm.io/npm:three@0.160.0/build/three.module.js"
