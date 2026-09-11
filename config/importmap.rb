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
pin_all_from "app/javascript/file_controllers", under: "file_controllers"
pin_all_from 'app/javascript/src', under: 'src', to: 'src'

pin "@videojs/html/video", to: "https://cdn.jsdelivr.net/npm/@videojs/cdn@10.0.0-rc.2/video.js"
pin "@videojs/html/media/hlsjs-video", to: "https://cdn.jsdelivr.net/npm/@videojs/cdn@10.0.0-rc.2/media/hlsjs-video.js"

pin "openseadragon", to: "https://ga.jspm.io/npm:openseadragon@4.1.0/build/openseadragon/openseadragon.js"
pin "fscreen", to: "https://ga.jspm.io/npm:fscreen@1.2.0/dist/fscreen.cjs.js"
pin "@google/model-viewer", to: "https://cdn.jsdelivr.net/npm/@google/model-viewer@3.5.0/dist/model-viewer-module.min.js"
pin "three", to: "https://ga.jspm.io/npm:three@0.163.0/build/three.module.js"
pin "popper", to: 'https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/esm/popper.js'

# The mirador viewer needs a local copy of ogm-viewer in node_modules to bundle,
# but the geo viewer uses importmaps, and Propshaft can't serve the node_modules
# version in a way that plays nice in the browser. Since we're stuck with two
# copies, make the package.json version authoritative, so they don't get out of sync.
ogm_viewer_version = JSON.parse(Rails.root.join('package.json').read).fetch('dependencies').fetch('ogm-viewer')
ogm_viewer = "https://cdn.jsdelivr.net/npm/ogm-viewer@#{ogm_viewer_version}/dist/components"

# Two pins that go into the same location: one is the components, the other is
# the classes used to build Resources and Previewers to put into them. Pinning
# into the same path means we only get one copy of maplibre-gl.
pin "ogm-viewer", to: "#{ogm_viewer}/ogm-viewer.js"
pin "ogm-viewer/lib", to: "#{ogm_viewer}/index.js"
