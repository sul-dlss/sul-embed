import { Controller } from "@hotwired/stimulus"

// Which data attribute holds the file, and what kind of thing is at it. Checked in this order, which
// is the order the Ruby side writes them in (see Embed::Viewer::Geo#map_element_options) - a record
// only ever carries one. The resource is named rather than imported: the module it comes from is
// fetched on demand, so at parse time there is no class here to point at.
const SOURCES = [
  { key: "indexMap", resource: "OpenIndexMapResource" },
  { key: "geoJson", resource: "GeoJsonResource" },
  { key: "pmtiles", resource: "PMTilesResource" },
  { key: "cogUrl", resource: "CogResource" },
]

// The data attributes that hold a visualization file URL, for the auth handshake to match against
const URL_KEYS = SOURCES.map(source => source.key)

// The viewer is about a megabyte gzipped across both pins, and every viewer in sul-embed loads the
// controllers index, which registers this file - so importing it at the top meant a 3D object's page
// downloaded a map it was never going to draw. Fetched once instead, by the first map that needs it:
// the first import defines the eleven elements as a side effect, and the second hands back the
// classes those elements use internally. Both pins point into one dist directory, so there is a
// single copy of maplibre-gl and a previewer built here is the same kind of object <ogm-map> would
// have built for itself.
let viewerModule
function loadViewer() {
  viewerModule ||= Promise.all([
    import("ogm-viewer"),
    import("ogm-viewer/lib"),
  ]).then(([, lib]) => lib)

  return viewerModule
}

export default class extends Controller {
  connect() {
    this.el = document.getElementById("sul-embed-geo-map")
    this.dataAttributes = this.el.dataset
    // Distinguishes each resource this controller builds, so the authorized reload doesn't collide
    // with the layer ids the outline before it left behind
    this.generation = 0

    this.whenVisible(() => {
      // For restricted content, outline where the record is until auth succeeds.
      // For public content, load the visualization immediately.
      if (this.restricted) {
        this.showLocation()
      } else {
        this.showVisualization()
      }
    })
  }

  // Nothing is fetched and no element is built for a map nobody is looking at. A geo record's map is
  // the whole page, so this runs straight away; a georeferenced scan's map waits in a tab behind the
  // image until someone opens it. Keyed on the panel being hidden because that is exactly what
  // tab_controller toggles, so there is no second signal to keep in step with it.
  whenVisible(callback) {
    const panel = this.element.closest("[role=tabpanel]")
    if (!panel?.hidden) return callback()

    this.panelObserver = new MutationObserver(() => {
      if (panel.hidden) return

      this.panelObserver.disconnect()
      callback()
    })
    this.panelObserver.observe(panel, { attributeFilter: ["hidden"] })
  }

  // Called after authorization success (by stimulus) for restricted content.
  // The IIIF manifest's painting body may be a different file (e.g., a .shp)
  // than the one the geo viewer renders (e.g., a .pmtiles).  When auth succeeds
  // for the wrong file, we request auth for the visualization file we actually
  // need.  Once that succeeds we update the URL with the authorized location and
  // load the visualization layer.
  show(evt) {
    const fileUri = evt.detail.fileUri

    // Auth was for a file the geo viewer doesn't render — request auth for the
    // file we actually need (e.g., pmtiles instead of shp).
    if (!this.matchesVisualizationUrl(fileUri)) {
      if (!this.authRequested) {
        const vizUrl = this.visualizationUrl()
        if (vizUrl) {
          this.authRequested = true
          window.dispatchEvent(
            new CustomEvent("thumbnail-clicked", {
              detail: { fileUri: vizUrl },
            }),
          )
        }
      }
      return
    }

    this.applyAuthorizedLocation(fileUri, evt.detail.location)
    this.showVisualization()
  }

  disconnect() {
    this.panelObserver?.disconnect()
    this.preview?.remove()
  }

  // The data-action attribute is only set for restricted content (see GeoComponent#data_actions)
  get restricted() {
    return !!this.element.dataset.action
  }

  // Read the IIIF auth v2 bearer token cached by file-auth-controller
  get authToken() {
    const json = localStorage.getItem("accessToken")
    if (!json) return null
    try {
      const { accessToken, expires } = JSON.parse(json)
      if (new Date() < new Date(expires)) return accessToken
    } catch {
      // ignore broken storage
    }
    return null
  }

  // Applied to every request the resource makes and, once its previewer attaches, to MapLibre's own
  // tile requests too. Credentials rather than the bearer token we hold: stacks answers a preflight
  // allowing Range and not Authorization, and it only sends back an allow-origin a credentialed
  // request can use when the Origin is one it knows - so a token would be refused before it was read.
  requestTransform() {
    if (!this.authToken) return undefined
    return () => ({ credentials: "include" })
  }

  // Replace the data-attribute URL matching fileUri with the authorized location
  applyAuthorizedLocation(fileUri, location) {
    if (!location) return
    for (const key of URL_KEYS) {
      if (this.dataAttributes[key] === fileUri) {
        this.el.dataset[key] = location
      }
    }
  }

  // Whether the given URL matches one of the visualization data attributes
  matchesVisualizationUrl(url) {
    return URL_KEYS.some(key => this.dataAttributes[key] === url)
  }

  // The URL of the primary visualization file the geo viewer renders
  visualizationUrl() {
    for (const key of URL_KEYS) {
      if (this.dataAttributes[key]) return this.dataAttributes[key]
    }
  }

  // Which of the data attributes this record carries, and the resource to read it with.
  source() {
    return SOURCES.find(({ key }) => this.dataAttributes[key])
  }

  // Build the resource this record points at, or nothing if it points at none - in which case the
  // outline of where it is stays up, the same as it did before.
  buildResource(viewer) {
    const source = this.source()
    if (!source) return undefined

    const url = this.dataAttributes[source.key]
    if (!url) return undefined

    return new viewer[source.resource](
      `sul-embed-geo-${this.generation++}`,
      url,
      this.boundingBox(),
      this.requestTransform(),
    )
  }

  async showVisualization() {
    const viewer = await loadViewer()
    const resource = this.buildResource(viewer)
    if (!resource) return this.showLocation()

    await this.showResource(resource)
  }

  // Hand the preview whichever of the resource's previews draws a map. Usually there is exactly one;
  // a georeferenced scan offers the image first and the map second, and here it is the map we came
  // for - the image is what the viewer in the next tab already is. A resource that offers no map at
  // all falls back to the outline, which is honest about knowing only where the thing is; showing
  // the image instead would put the same scan in both tabs and call one of them a map.
  async showResource(resource) {
    const viewer = await loadViewer()
    const previewers = await viewer.previewersFor(resource)
    const previewer = previewers.find(candidate => candidate.renderer === "map")
    if (!previewer) return this.showLocation()

    await this.attach(previewer)
  }

  // A DOM property, never an attribute - a previewer is an object. Set after the element is defined
  // and mounted: assigning before the map has loaded its style reaches addSource() too early and
  // MapLibre refuses with "Style is not done loading."
  async attach(previewer) {
    const preview = this.previewElement()
    await customElements.whenDefined("ogm-preview")
    await preview.componentOnReady?.()
    preview.previewer = previewer
  }

  // Built on first use rather than in connect(), so a map that is never looked at never reaches the
  // DOM at all. We don't support dark mode overall in sul-embed, so force light mode in the preview.
  previewElement() {
    if (!this.preview) {
      this.preview = document.createElement("ogm-preview")
      this.preview.theme = "light"
      this.el.appendChild(this.preview)
    }

    return this.preview
  }

  // Where the record is, when what it holds can't be shown: restricted content waiting on
  // authorization, or a record pointing at no file this viewer reads. The one resource made from a
  // shape rather than a URL, so it needs nothing fetched and can't fail, and the one drawn as a frame
  // around the extent rather than as data filling it - which is the difference between saying where a
  // thing is and appearing to show it. Nothing to click either: the box carries no properties, so a
  // popup would open on an empty table.
  async showLocation() {
    const bounds = this.boundingBox()
    if (!bounds) return

    // Straight to its previewer rather than back through showResource, which would come round here
    // again if it ever found no map to draw.
    const viewer = await loadViewer()
    const [previewer] = await viewer.previewersFor(
      new viewer.LocationResource(`sul-embed-geo-${this.generation++}`, bounds),
    )
    if (previewer) await this.attach(previewer)
  }

  // Bounding box is stored in Leaflet format: [[south, west], [north, east]]
  // MapLibre expects: [[west, south], [east, north]]
  boundingBox() {
    if (!this.dataAttributes.boundingBox) return undefined

    const bb = JSON.parse(this.dataAttributes.boundingBox)
    return [
      [Number(bb[0][1]), Number(bb[0][0])],
      [Number(bb[1][1]), Number(bb[1][0])],
    ]
  }
}
