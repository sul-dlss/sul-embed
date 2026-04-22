import { Controller } from "@hotwired/stimulus"
import "maplibre-gl"
import * as pmtiles from "pmtiles"
import { IndexMapRenderer } from "geo/index_map_renderer"

export default class extends Controller {
  connect() {
    this.el = document.getElementById("sul-embed-geo-map")
    this.dataAttributes = this.el.dataset

    this.map = this.createMap()

    this.map.addControl(new maplibregl.NavigationControl(), "top-left")
    this.map.on("load", () => this.addVisualizationLayer())
  }

  disconnect() {
    this.map?.remove()
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

  addVisualizationLayer() {
    if (this.isIndexMap()) {
      fetch(this.dataAttributes.indexMap)
        .then(response => response.json())
        .then(data => this.renderIndexMap(data))
    } else if (this.isGeoJSON()) {
      fetch(this.dataAttributes.geoJson)
        .then(response => response.json())
        .then(data => this.renderGeoJSON(data))
    } else if (this.isDefined(this.dataAttributes.pmtiles)) {
      this.renderPmtiles()
    } else {
      this.renderReplacementRectangle()
    }
  }

  renderIndexMap(data) {
    const renderer = new IndexMapRenderer(
      this.map,
      this.dataAttributes,
      this.el
    )
    renderer.render(data)
  }

  renderGeoJSON(data) {
    this.map.addSource("geo-json-source", { type: "geojson", data: data })
    const paint = {}
    if (this.layerType() === "fill") {
      paint["fill-color"] = "#4264fb"
      paint["fill-outline-color"] = "#fff"
    } else if (this.layerType() === "line") {
      paint["line-color"] = "#4264fb"
    } else if (this.layerType() === "circle") {
      paint["circle-color"] = "#4264fb"
      paint["circle-stroke-color"] = "#fff"
      paint["circle-stroke-width"] = 1
      paint["circle-radius"] = 8
    }
    this.map.addLayer({
      id: "geo-json-fill",
      type: this.layerType(),
      source: "geo-json-source",
      paint: paint
    })
  }

  renderPmtiles() {
    const pmtilesUrl = this.dataAttributes.pmtiles
    // add the PMTiles plugin to the maplibregl global.
    const protocol = new pmtiles.Protocol()
    maplibregl.addProtocol("pmtiles", protocol.tile)

    const p = new pmtiles.PMTiles(pmtilesUrl)

    // this is so we share one instance across the JS code and the map renderer
    protocol.add(p)

    // we first fetch the header so we can get the bounding box of the map.
    p.getHeader().then(h => {
      const bounds = new maplibregl.LngLatBounds(
        [h.minLon, h.minLat],
        [h.maxLon, h.maxLat]
      )
      if (!bounds.isEmpty()) this.map.fitBounds(bounds, { padding: 20 })
    })

    this.map.addSource("pmtiles-source", {
      type: "vector",
      url: `pmtiles://${pmtilesUrl}`
    })
    this.map.addLayer({
      id: "pmtiles-layer",
      type: "line",
      source: "pmtiles-source",
      "source-layer": "landuse",
      type: "fill",
      paint: {
        "fill-color": "steelblue"
      }
    })
  }

  layerType() {
    return this.dataAttributes.layerType || "circle"
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
