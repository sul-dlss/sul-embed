export class IndexMapRenderer {
  constructor(map, dataAttributes, openSidebarWithContent, highlightFeature) {
    this.map = map
    this.dataAttributes = dataAttributes
    this.openSidebarWithContent = openSidebarWithContent
    this.highlightFeature = highlightFeature
  }

  render(data) {
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
      filter: ["==", ["geometry-type"], "Polygon"],
      source: "index-map-source",
      paint: { "fill-color": colorExpr, "fill-opacity": 0.2 }
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

    const popup = new maplibregl.Popup({
      closeButton: false,
      closeOnClick: false
    })

    const interactiveLayers = ["index-map-fill", "index-map-circle"]

    // Show a tooltip on mouse move
    this.map.on("mousemove", e => {
      const features = this.map.queryRenderedFeatures(e.point, {
        layers: interactiveLayers
      })
      if (features.length > 0) {
        this.map.getCanvas().style.cursor = "pointer"
        const { label } = features[0].properties
        if (label != null) {
          popup.setLngLat(e.lngLat).setHTML(String(label)).addTo(this.map)
        }
      } else {
        this.map.getCanvas().style.cursor = ""
        popup.remove()
      }
    })

    for (const layerId of interactiveLayers) {
      this.map.on("click", layerId, e => {
        const feature = e.features[0]
        const { available } = feature.properties
        if (available !== null && available !== undefined) {
          this.highlightFeature(feature)
          this.indexMapInspection(feature.properties)
        }
      })
    }
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
    if (data.available && data.iiifUrl)
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
}
