# Pin npm packages by running ./bin/importmap

pin "media", preload: true
pin "file", preload: true
pin "document", preload: true
pin "model", preload: true
pin "geo", preload: true
pin "webarchive", preload: true

pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from 'app/javascript/geo', under: 'geo'
pin_all_from "app/javascript/file_controllers", under: "file_controllers"
pin_all_from 'app/javascript/src', under: 'src', to: 'src'

pin "@videojs/html/video", to: "https://cdn.jsdelivr.net/npm/@videojs/html@10.0.0-beta.25/cdn/video.js"
pin "@videojs/html/media/hlsjs-video", to: "https://cdn.jsdelivr.net/npm/@videojs/html@10.0.0-beta.25/cdn/media/hlsjs-video.js"

pin "openseadragon", to: "https://ga.jspm.io/npm:openseadragon@4.1.0/build/openseadragon/openseadragon.js"
pin "fscreen", to: "https://ga.jspm.io/npm:fscreen@1.2.0/dist/fscreen.cjs.js"
pin "@google/model-viewer", to: "https://cdn.jsdelivr.net/npm/@google/model-viewer@3.5.0/dist/model-viewer-module.min.js"
pin "three", to: "https://ga.jspm.io/npm:three@0.163.0/build/three.module.js"
pin "popper", to: 'https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/esm/popper.js'
pin "maplibre-gl" # @5.21.1
pin "pmtiles" # @4.4.0
pin "fflate" # @0.8.2

# These files are built by https://github.com/sul-dlss/deck-gl-web
# we have copied them into the `vendor` directory
pin "deck-gl-web" # renamed from index.js
pin "decode"
pin "deflate"
pin "lerc"
pin "lzw"
pin "LercDecode.es"
pin "utils"
pin "webgl-device"
pin "webgl-device2"

pin "allmaps" # Derived from @allmaps/maplibre
pin "chunk"
pin "lib"
