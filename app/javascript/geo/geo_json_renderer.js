export class GeoJsonRenderer {
  constructor(
    map,
    dataAttributes,
    openSidebarWithContent,
    highlightFeature,
    setupSidebar,
    addOpacityControl
  ) {
    this.map = map
    this.dataAttributes = dataAttributes
    this.openSidebarWithContent = openSidebarWithContent
    this.highlightFeature = highlightFeature
    this.setupSidebar = setupSidebar
    this.addOpacityControl = addOpacityControl
  }

  layerType() {
    return this.dataAttributes.layerType || "circle"
  }

  render(data) {
    const type = this.layerType()
    const layerId = "geo-json-layer"

    this.map.addSource("geo-json-source", { type: "geojson", data })

    const paint = {}
    if (type === "fill") {
      paint["fill-color"] = "#4264fb"
      paint["fill-outline-color"] = "#fff"
      paint["fill-opacity"] = 0.75
    } else if (type === "line") {
      paint["line-color"] = "#4264fb"
      paint["line-opacity"] = 0.75
    } else {
      paint["circle-color"] = "#4264fb"
      paint["circle-stroke-color"] = "#fff"
      paint["circle-stroke-width"] = 1
      paint["circle-radius"] = 8
      paint["circle-opacity"] = 0.75
    }

    this.map.addLayer({
      id: layerId,
      type,
      source: "geo-json-source",
      paint
    })

    // Hover tooltip
    const popup = new maplibregl.Popup({
      closeButton: false,
      closeOnClick: false
    })

    const interactiveLayers = [layerId]

    // Show a tooltip on mouse move
    this.map.on("mousemove", e => {
      const features = this.map.queryRenderedFeatures(e.point, {
        layers: interactiveLayers
      })
      if (features.length > 0) {
        this.map.getCanvas().style.cursor = "pointer"
        const feature = features[0]

        const label =
          feature.properties.NAME ||
          feature.properties.label ||
          feature.properties.title ||
          `Feature ID: ${feature.id || "Unknown"}`
        if (label != null) {
          popup.setLngLat(e.lngLat).setHTML(String(label)).addTo(this.map)
        }
      } else {
        this.map.getCanvas().style.cursor = ""
        popup.remove()
      }
    })

    this.map.on("click", layerId, e => {
      const feature = e.features[0]
      this.highlightFeature(feature)
      this.inspection(feature.properties)
    })

    const opacityProperty = {
      fill: "fill-opacity",
      line: "line-opacity",
      circle: "circle-opacity"
    }[type]

    this.setupSidebar()
    this.addOpacityControl([{ id: layerId, property: opacityProperty }], 0.75)
  }

  inspection(properties) {
    this.openSidebarWithContent(this.info({ ...properties }))
  }

  info(data) {
    let output = '<div class="geo-json-info"><div><dl>'

    Object.entries(data).forEach(([key, value]) => {
      if (value !== null && value !== undefined && value !== "") {
        const formattedKey = key
          .replace(/_/g, " ")
          .replace(/\b\w/g, l => l.toUpperCase())
        output += `<dt>${formattedKey}</dt><dd>${value}</dd>`
      }
    })

    return output + "</dl></div></div>"
  }
}
