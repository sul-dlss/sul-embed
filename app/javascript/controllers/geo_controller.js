import { Controller } from "@hotwired/stimulus"
import "maplibre-gl"
import { IndexMapRenderer } from "geo/index_map_renderer"
import { PmtilesRenderer } from "geo/pmtiles_renderer"
import { SidebarControl } from "geo/sidebar_control"
import { OpacityControl } from "geo/opacity_control"

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
    } else if (this.isXYZTiles()) {
      this.renderXYZTiles()
    } else {
      this.renderReplacementRectangle()
    }
  }

  isXYZTiles() {
    return this.isDefined(this.dataAttributes.xyzTiles)
  }

  renderXYZTiles() {
    const xyzTiles = this.dataAttributes.xyzTiles
    this.map.addSource("xyz-tiles-source", {
      type: "raster",
      url: xyzTiles
    })
    this.map.addLayer({
      id: "xyz-tiles-layer",
      type: "raster",
      source: "xyz-tiles-source",
      paint: {
        "raster-opacity": 1
      }
    })
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
    this.addOpacityControl(
      [
        { id: "index-map-fill", property: "fill-opacity" },
        { id: "index-map-circle", property: "circle-opacity" }
      ],
      0.75
    )
  }

  setupSidebar() {
    this.sidebarControl = new SidebarControl(`${this.el.clientHeight - 100}px`)
    this.map.addControl(this.sidebarControl, "top-right")
  }

  // Reimplements L.Control.LayerOpacity as a vanilla-JS MapLibre IControl,
  // reusing the existing .opacity-control CSS from geo.css.
  addOpacityControl(layerSpecs, initialOpacity = 0.75) {
    this.map.addControl(
      new OpacityControl(layerSpecs, initialOpacity),
      "top-left"
    )
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
    const renderer = new PmtilesRenderer(
      this.map,
      this.dataAttributes.pmtiles,
      this.openSidebarWithContent.bind(this),
      this.highlightFeature.bind(this)
    )
    renderer.render()

    this.setupSidebar()
    this.addOpacityControl(
      [{ id: "pmtiles-layer", property: "fill-opacity" }],
      0.75
    )
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
