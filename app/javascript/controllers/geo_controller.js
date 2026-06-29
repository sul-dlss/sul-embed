import { Controller } from "@hotwired/stimulus"
import "maplibre-gl"
import { IndexMapRenderer } from "geo/index_map_renderer"
import { PmtilesRenderer } from "geo/pmtiles_renderer"
import { GeoJsonRenderer } from "geo/geo_json_renderer"
import { IiifGeoreferenceRenderer } from "geo/iiif_georeference_renderer"
import { SidebarControl } from "geo/sidebar_control"
import { OpacityControl } from "geo/opacity_control"

export default class extends Controller {
  connect() {
    this.el = document.getElementById("sul-embed-geo-map")
    this.dataAttributes = this.el.dataset
    this.loaded = false
    this.map = this.createMap()

    this.map.addControl(new maplibregl.NavigationControl(), "top-left")
    this.map.on("load", () => {
      this.loaded = true
      // For restricted content, show the bounding-box placeholder until auth succeeds.
      // For public content, load the visualization immediately.
      if (this.restricted) {
        this.renderReplacementRectangle()
      } else {
        this.addVisualizationLayer()
      }
    })
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
          window.dispatchEvent(new CustomEvent("thumbnail-clicked", { detail: { fileUri: vizUrl } }))
        }
      }
      return
    }

    this.applyAuthorizedLocation(fileUri, evt.detail.location)

    const loadVisualization = () => {
      this.removeReplacementLayers()
      this.addVisualizationLayer()
    }
    if (this.loaded) {
      loadVisualization()
    } else {
      this.map.once("load", loadVisualization)
    }
  }

  disconnect() {
    this.map?.remove()
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

  // Request options that include credentials so restricted files are served
  // directly via the stacks auth cookie (avoids CORS preflight issues that
  // arise from using an Authorization header)
  authedFetchOptions() {
    const token = this.authToken
    return token ? { credentials: "include" } : {}
  }

  // Replace the data-attribute URL matching fileUri with the authorized location
  applyAuthorizedLocation(fileUri, location) {
    if (!location) return
    const urlKeys = ["indexMap", "geoJson", "pmtiles", "cogUrl", "annotationsUrl"]
    for (const key of urlKeys) {
      if (this.dataAttributes[key] === fileUri) {
        this.el.dataset[key] = location
      }
    }
  }

  // The data-attribute keys that hold visualization file URLs
  visualizationUrlKeys() {
    return ["indexMap", "geoJson", "pmtiles", "cogUrl", "annotationsUrl"]
  }

  // Whether the given URL matches one of the visualization data attributes
  matchesVisualizationUrl(url) {
    return this.visualizationUrlKeys().some(key => this.dataAttributes[key] === url)
  }

  // The URL of the primary visualization file the geo viewer renders
  visualizationUrl() {
    for (const key of this.visualizationUrlKeys()) {
      if (this.dataAttributes[key]) return this.dataAttributes[key]
    }
  }

  // Remove the placeholder rectangle layers shown while content is locked
  removeReplacementLayers() {
    if (this.map.getLayer("replacement-fill")) this.map.removeLayer("replacement-fill")
    if (this.map.getLayer("replacement-line")) this.map.removeLayer("replacement-line")
    if (this.map.getSource("replacement-source")) this.map.removeSource("replacement-source")
  }

  createMap() {
    const prefersDark =
      window.matchMedia &&
      window.matchMedia("(prefers-color-scheme: dark)").matches

    const style = prefersDark
      ? "https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json"
      : "https://basemaps.cartocdn.com/gl/positron-gl-style/style.json"

    return new maplibregl.Map({
      container: "sul-embed-geo-map",
      style: style,
      bounds: this.boundingBox()
    })
  }

  // Bounding box is stored in Leaflet format: [[south, west], [north, east]]
  // MapLibre fitBounds expects: [[west, south], [east, north]]
  boundingBox() {
    if (!this.dataAttributes.boundingBox) {
      return [
        [-180, -90],
        [180, 90]
      ]
    }
    const bb = JSON.parse(this.dataAttributes.boundingBox)
    return [
      [bb[0][1], bb[0][0]],
      [bb[1][1], bb[1][0]]
    ]
  }

  isDefined(obj) {
    return typeof obj !== "undefined"
  }

  // Are we dealing with an index map?
  isIndexMap() {
    return (
      this.isDefined(this.dataAttributes.indexMap) &&
      this.dataAttributes.indexMap !== ""
    )
  }

  // Are we dealing with GeoJSON?
  isGeoJSON() {
    return (
      this.isDefined(this.dataAttributes.geoJson) &&
      this.dataAttributes.geoJson !== ""
    )
  }

  isCOG() {
    return (
      this.isDefined(this.dataAttributes.cogUrl) &&
      this.dataAttributes.cogUrl !== ""
    )
  }

  isIIIFAnnotation() {
    return (
      this.isDefined(this.dataAttributes.annotationsUrl) &&
      this.dataAttributes.annotationsUrl !== ""
    )
  }

  addVisualizationLayer() {
    if (this.isIndexMap()) {
      fetch(this.dataAttributes.indexMap, this.authedFetchOptions())
        .then(response => response.json())
        .then(data => this.renderIndexMap(data))
    } else if (this.isIIIFAnnotation()) {
      this.renderIIIFAnnotation(this.dataAttributes.annotationsUrl)
    } else if (this.isGeoJSON()) {
      fetch(this.dataAttributes.geoJson, this.authedFetchOptions())
        .then(response => response.json())
        .then(data => this.renderGeoJSON(data))
    } else if (this.isDefined(this.dataAttributes.pmtiles)) {
      this.renderPmtiles()
    } else if (this.isCOG()) {
      this.renderCOG(this.dataAttributes.cogUrl)
    } else {
      this.renderReplacementRectangle()
    }
  }

  renderIndexMap(data) {
    const renderer = new IndexMapRenderer(
      this.map,
      this.dataAttributes,
      this.openSidebarWithContent.bind(this),
      this.highlightFeature.bind(this)
    )
    renderer.render(data)

    this.setupSidebar()
    this.addOpacityControl(opacity => {
      this.map.setPaintProperty("index-map-fill", "fill-opacity", opacity)
      this.map.setPaintProperty("index-map-circle", "circle-opacity", opacity)
    }, 0.75)
  }

  setupSidebar() {
    this.sidebarControl = new SidebarControl(`${this.el.clientHeight - 100}px`)
    this.map.addControl(this.sidebarControl, "top-right")
  }

  async renderCOG() {
    const { CogRenderer } = await import("geo/cog_renderer")

    const renderer = new CogRenderer(
      this.map,
      this.dataAttributes.cogUrl,
      this.addOpacityControl.bind(this)
    )
    renderer.render()
  }

  // Reimplements L.Control.LayerOpacity as a vanilla-JS MapLibre IControl,
  // reusing the existing .opacity-control CSS from geo.css.
  addOpacityControl(callback, initialOpacity = 0.75) {
    this.map.addControl(
      new OpacityControl(callback, initialOpacity),
      "top-left"
    )
  }

  renderGeoJSON(data) {
    const renderer = new GeoJsonRenderer(
      this.map,
      this.dataAttributes,
      this.openSidebarWithContent.bind(this),
      this.highlightFeature.bind(this),
      this.setupSidebar.bind(this),
      this.addOpacityControl.bind(this)
    )
    renderer.render(data)
  }

  renderPmtiles() {
    const renderer = new PmtilesRenderer(
      this.map,
      this.dataAttributes.pmtiles,
      this.openSidebarWithContent.bind(this),
      this.highlightFeature.bind(this),
      this.authToken
    )
    renderer.render()

    this.setupSidebar()
    this.addOpacityControl(
      opacity =>
        this.map.setPaintProperty("pmtiles-layer", "fill-opacity", opacity),
      0.75
    )
  }

  async renderIIIFAnnotation(annotationUrl) {
    const renderer = new IiifGeoreferenceRenderer(
      this.map,
      annotationUrl,
      this.addOpacityControl.bind(this)
    )
    renderer.render()
  }

  // Highlight a single GeoJSON feature (e.g. from an index map click).
  // e.features[0] is a MapGeoJSONFeature (a MapLibre-specific class), not a
  // plain object. Reconstruct it as plain GeoJSON so MapLibre can serialize it
  // to its web worker when adding it as a GeoJSON source.
  highlightFeature(feature) {
    this.setHighlightData({
      type: "FeatureCollection",
      features: [
        {
          type: "Feature",
          geometry: feature.geometry,
          properties: { ...feature.properties }
        }
      ]
    })
  }

  setHighlightData(geojsonData) {
    const color = JSON.parse(this.dataAttributes.geoViewerColors).selected

    if (this.map.getSource("highlight-source")) {
      this.map.getSource("highlight-source").setData(geojsonData)
    } else {
      this.map.addSource("highlight-source", {
        type: "geojson",
        data: geojsonData
      })

      this.map.addLayer({
        id: "highlight-fill",
        type: "fill",
        source: "highlight-source",
        filter: ["==", ["geometry-type"], "Polygon"],
        paint: { "fill-color": color, "fill-opacity": 0.5 }
      })

      this.map.addLayer({
        id: "highlight-line",
        type: "line",
        source: "highlight-source",
        paint: { "line-color": color, "line-width": 2 }
      })

      this.map.addLayer({
        id: "highlight-circle",
        type: "circle",
        source: "highlight-source",
        filter: ["==", ["geometry-type"], "Point"],
        paint: {
          "circle-radius": 8,
          "circle-color": color,
          "circle-opacity": 0.7
        }
      })
    }
  }

  openSidebarWithContent(html) {
    this.sidebarControl.openWithContent(html)
  }

  renderReplacementRectangle() {
    // Restricted layer: show the bounding box outline instead of the real layer
    const bb = this.boundingBox()
    const [west, south] = bb[0]
    const [east, north] = bb[1]

    this.map.addSource("replacement-source", {
      type: "geojson",
      data: {
        type: "Feature",
        geometry: {
          type: "Polygon",
          coordinates: [
            [
              [west, south],
              [east, south],
              [east, north],
              [west, north],
              [west, south]
            ]
          ]
        }
      }
    })

    this.map.addLayer({
      id: "replacement-fill",
      type: "fill",
      source: "replacement-source",
      paint: { "fill-color": "#0000FF", "fill-opacity": 0.05 }
    })

    this.map.addLayer({
      id: "replacement-line",
      type: "line",
      source: "replacement-source",
      paint: { "line-color": "#0000FF", "line-width": 4 }
    })

    this.replacementLayerAdded = true
  }
}
