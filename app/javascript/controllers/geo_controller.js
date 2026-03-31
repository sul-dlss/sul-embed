import { Controller } from "@hotwired/stimulus"
import "maplibre-gl"
import * as pmtiles from "pmtiles"
import "jcoyne-maplibre-cog-protocol"

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
    } else if (this.isDefined(this.dataAttributes.geotiff)) {
      this.renderGeoTiff(this.dataAttributes.geotiff)
      // this.renderGeoTiff("http://localhost:3000/cog.tif")
    } else {
      this.renderReplacementRectangle()
    }
  }

  renderGeoJSON(data) {
    this.map.addSource("geo-json-source", { type: "geojson", data: data })
    this.map.addLayer({
      id: "geo-json-fill",
      type: this.layerType(),
      source: "geo-json-source",
      paint: {
        "circle-color": "#4264fb",
        "circle-radius": 8
      }
    })
  }

  async renderGeoTiff(geotiffUrl) {
    maplibregl.addProtocol("cog", MaplibreCOGProtocol.cogProtocol)

    // getCogMetadata is marked [unstable] in the maplibre-cog-protocol API
    const metadata = await MaplibreCOGProtocol.getCogMetadata(geotiffUrl)
    console.log("Bounding box", metadata)
    if (metadata?.bbox)
      this.map.fitBounds(metadata.bbox, { padding: 20, animate: false })

    console.log("Current zoom", this.map.getZoom())
    this.map.addSource("cog-source", {
      type: "raster",
      url: `cog://${geotiffUrl}`,
      tileSize: 256
    })
    this.map.addLayer({
      id: "geo-tiff-fill",
      type: "raster",
      source: "cog-source"
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

  renderIndexMap(data) {
    const colors = JSON.parse(this.dataAttributes.geoViewerColors)

    // Replicates availabilityStyle logic as a MapLibre data-driven expression:
    // missing or null → Leaflet-default blue; true → available color; false → unavailable color
    const colorExpr = [
      "case",
      ["!", ["has", "available"]],
      "#3388ff",
      ["==", ["get", "available"], null],
      "#3388ff",
      ["get", "available"],
      colors.available,
      colors.unavailable
    ]

    this.map.addSource("index-map-source", { type: "geojson", data })

    this.map.addLayer({
      id: "index-map-fill",
      type: "fill",
      source: "index-map-source",
      filter: ["==", ["geometry-type"], "Polygon"],
      paint: { "fill-color": colorExpr, "fill-opacity": 0.75 }
    })

    this.map.addLayer({
      id: "index-map-line",
      type: "line",
      source: "index-map-source",
      paint: { "line-color": colorExpr, "line-width": 1 }
    })

    this.map.addLayer({
      id: "index-map-circle",
      type: "circle",
      source: "index-map-source",
      filter: ["==", ["geometry-type"], "Point"],
      paint: {
        "circle-radius": 4,
        "circle-color": colorExpr,
        "circle-stroke-width": 1,
        "circle-stroke-color": "#fff",
        "circle-opacity": 0.75
      }
    })

    const bounds = this.getBoundsFromGeoJSON(data)
    if (!bounds.isEmpty()) this.map.fitBounds(bounds, { padding: 20 })

    // Hover tooltip popup (replaces bindTooltip)
    const popup = new maplibregl.Popup({
      closeButton: false,
      closeOnClick: false
    })

    const showTooltip = e => {
      this.map.getCanvas().style.cursor = "pointer"
      const { label } = e.features[0].properties
      if (label != null)
        popup.setLngLat(e.lngLat).setHTML(String(label)).addTo(this.map)
    }
    const hideTooltip = () => {
      this.map.getCanvas().style.cursor = ""
      popup.remove()
    }

    for (const layerId of ["index-map-fill", "index-map-circle"]) {
      this.map.on("mouseenter", layerId, showTooltip)
      this.map.on("mouseleave", layerId, hideTooltip)
      this.map.on("click", layerId, e => {
        const feature = e.features[0]
        const { available } = feature.properties
        if (available !== null && available !== undefined) {
          this.highlightFeature(feature)
          this.indexMapInspection(feature.properties)
        }
      })
    }

    this.setupSidebar()
    this.addOpacityControl(
      [
        { id: "index-map-fill", property: "fill-opacity" },
        { id: "index-map-circle", property: "circle-opacity" }
      ],
      0.75
    )
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

  getBoundsFromGeoJSON(data) {
    const bounds = new maplibregl.LngLatBounds()
    data.features.forEach(feature => {
      if (feature.geometry) this.extendBounds(bounds, feature.geometry)
    })
    return bounds
  }

  extendBounds(bounds, geometry) {
    const { type, coordinates } = geometry
    if (type === "Point") {
      bounds.extend(coordinates)
    } else if (type === "LineString" || type === "MultiPoint") {
      coordinates.forEach(c => bounds.extend(c))
    } else if (type === "Polygon" || type === "MultiLineString") {
      coordinates.forEach(ring => ring.forEach(c => bounds.extend(c)))
    } else if (type === "MultiPolygon") {
      coordinates.forEach(poly =>
        poly.forEach(ring => ring.forEach(c => bounds.extend(c)))
      )
    } else if (type === "GeometryCollection") {
      geometry.geometries.forEach(g => this.extendBounds(bounds, g))
    }
  }

  indexMapInfo(data) {
    let output = '<div class="index-map-info"><div>'

    if (data.thumbnailUrl) {
      const img = `<img src="${data.thumbnailUrl}" style="max-width: 100%; height: auto" alt="">`
      output += data.websiteUrl
        ? `<a href="${data.websiteUrl}" title="View this map" target="_blank">${img}</a>`
        : img
    }

    output += "<dl>"
    if (data.sheet) output += `<dt>Sheet</dt><dd>${data.sheet}</dd>`
    if (data.label) output += `<dt>Label</dt><dd>${data.label}</dd>`
    if (data.note) output += `<dt>Note</dt><dd>${data.note}</dd>`
    if (data.call_num) output += `<dt>Call number</dt><dd>${data.call_num}</dd>`
    if (data.websiteUrl)
      output += `<dt>Web link</dt><dd><a target="_blank" href="${data.websiteUrl}">View this map</a></dd>`
    if (data.downloadUrl)
      output += `<dt>Download</dt><dd><a target="_blank" href="${data.downloadUrl}">Download this map</a></dd>`
    if (data.iiifUrl)
      output += `<dt>IIIF manifest</dt><dd><a target="_blank" href="${data.iiifUrl}">View manifest</a></dd>`

    return output + "</dl></div></div>"
  }

  indexMapInspection(properties) {
    // Spread into a plain object so we can safely attach thumbnailUrl
    const data = { ...properties }

    const thumbPromise = new Promise(resolve => {
      if (data.iiifUrl) {
        fetch(data.iiifUrl)
          .then(r => r.json())
          .then(manifest => {
            if (manifest.thumbnail?.["@id"])
              data.thumbnailUrl = manifest.thumbnail["@id"]
            resolve()
          })
          .catch(resolve)
      } else {
        resolve()
      }
    })

    thumbPromise.then(() =>
      this.openSidebarWithContent(this.indexMapInfo(data))
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
    const sidebar = this.el.querySelector(".sul-embed-geo-sidebar")
    const button = sidebar.querySelector("button")
    const content = sidebar.querySelector(".sul-embed-geo-sidebar-content")
    button.setAttribute("aria-expanded", "true")
    content.classList.add("show")
    content.innerHTML = html
    content.style.maxHeight = `${this.el.clientHeight - 90}px`
    content.setAttribute("aria-hidden", "false")
  }

  geoSidebar() {
    const title = this.isIndexMap() ? "Map Sheet" : "Features"
    const body = this.isIndexMap()
      ? "Click the map to inspect a sheet."
      : "Click the map to inspect features."

    return `<div class="sul-embed-geo-sidebar">
                  <div class="sul-embed-geo-sidebar-header">
                    <h3>${title}</h3>
                    <button aria-label="expand/collapse" aria-expanded="true" aria-controls="sidebarContent">
                      <svg class="MuiSvgIcon-root KeyboardArrowUpSharp" focusable="false" aria-hidden="true" viewBox="0 0 24 24"><path d="M7.41 15.41 12 10.83l4.59 4.58L18 14l-6-6-6 6z"></path></svg>
                    </button>
                  </div>
                  <div id="sidebarContent" class="sul-embed-geo-sidebar-content show">${body}</div>
                </div>`
  }

  setupSidebar() {
    const sidebarControl = {
      onAdd: () => {
        const container = document.createElement("div")
        container.className = "maplibregl-ctrl"
        container.innerHTML = this.geoSidebar()
        container.addEventListener("click", e => {
          const button = e.target.closest("button")
          if (!button) return
          const contentEl = document.getElementById(
            button.getAttribute("aria-controls")
          )
          const expanded = button.getAttribute("aria-expanded") === "true"
          contentEl.classList.toggle("show", !expanded)
          button.setAttribute("aria-expanded", String(!expanded))
        })
        return container
      },
      onRemove: () => {}
    }
    this.map.addControl(sidebarControl, "top-right")
  }

  // Reimplements L.Control.LayerOpacity as a vanilla-JS MapLibre IControl,
  // reusing the existing .opacity-control CSS from geo.css.
  addOpacityControl(layerSpecs, initialOpacity = 0.75) {
    let mouseMoveHandler, mouseUpHandler

    const opacityControl = {
      onAdd: map => {
        const opacityPercent = Math.round(initialOpacity * 100)

        const container = document.createElement("div")
        container.className = "opacity-control unselectable maplibregl-ctrl"

        const area = document.createElement("div")
        area.className = "opacity-area"

        const handle = document.createElement("div")
        handle.className = "opacity-handle"
        handle.setAttribute("tabindex", "0")
        handle.innerHTML = `
          <div class="opacity-arrow-up"></div>
          <div class="opacity-text">${opacityPercent}%</div>
          <div class="opacity-arrow-down"></div>`

        const bottom = document.createElement("div")
        bottom.className = "opacity-bottom"

        container.append(area, handle, bottom)

        handle.style.top = `calc(100% - ${opacityPercent}% - 12px)`
        bottom.style.top = `calc(100% - ${opacityPercent}%)`
        bottom.style.height = `${opacityPercent}%`

        // Prevent map interactions from passing through the control
        container.addEventListener("click", e => e.stopPropagation())
        container.addEventListener("mousedown", e => e.stopPropagation())

        const updateOpacity = opacity => {
          layerSpecs.forEach(({ id, property }) => {
            if (map.getLayer(id)) map.setPaintProperty(id, property, opacity)
          })
        }

        let dragStart = null
        let dragStartTop

        handle.addEventListener("mousedown", e => {
          dragStart = e.clientY
          dragStartTop = handle.offsetTop - 12
        })

        mouseMoveHandler = e => {
          if (dragStart === null) return
          const percentInverse =
            Math.max(0, Math.min(200, dragStartTop + e.clientY - dragStart)) / 2
          handle.style.top = `${percentInverse * 2 - 13}px`
          handle.querySelector(".opacity-text").innerHTML =
            `${Math.round((1 - percentInverse / 100) * 100)}%`
          bottom.style.height = `${Math.max(0, (100 - percentInverse) * 2 - 13)}px`
          bottom.style.top = `${Math.min(200, percentInverse * 2 + 13)}px`
          updateOpacity(1 - percentInverse / 100)
        }

        mouseUpHandler = () => {
          dragStart = null
        }

        document.addEventListener("mousemove", mouseMoveHandler)
        document.addEventListener("mouseup", mouseUpHandler)

        handle.addEventListener("keydown", e => {
          const current = parseInt(
            handle.querySelector(".opacity-text").innerHTML
          )
          let next =
            e.key === "ArrowUp"
              ? current + 1
              : e.key === "ArrowDown"
                ? current - 1
                : null
          if (next === null) return
          e.preventDefault()
          next = Math.max(0, Math.min(100, next))
          handle.style.top = `calc(100% - ${next}% - 12px)`
          handle.querySelector(".opacity-text").innerHTML = `${next}%`
          bottom.style.height = `${next}%`
          bottom.style.top = `calc(100% - ${next}%)`
          updateOpacity(next / 100)
        })

        return container
      },
      onRemove: () => {
        document.removeEventListener("mousemove", mouseMoveHandler)
        document.removeEventListener("mouseup", mouseUpHandler)
      }
    }

    this.map.addControl(opacityControl, "top-left")
  }
}
