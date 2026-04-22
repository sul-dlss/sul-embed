import * as pmtiles from "pmtiles"

export class PmtilesRenderer {
  constructor(map, pmtilesUrl, openSidebarWithContent, highlightFeature) {
    this.map = map
    this.pmtilesUrl = pmtilesUrl
    this.openSidebarWithContent = openSidebarWithContent
    this.highlightFeature = highlightFeature
  }

  render() {
    // add the PMTiles plugin to the maplibregl global.
    const protocol = new pmtiles.Protocol()
    maplibregl.addProtocol("pmtiles", protocol.tile)

    const p = new pmtiles.PMTiles(this.pmtilesUrl)

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

    // then, fetch the metadata to check how many layers are in the PMTile and
    // get their names. use this to add the layer to the map.
    p.getMetadata().then(metadata => {
      // bail out if no layers are found
      if (metadata.vector_layers.length == 0) {
        console.error("No vector layers found in PMTiles metadata", metadata)
        return
      }

      // add a source
      this.map.addSource("pmtiles-source", {
        type: "vector",
        url: `pmtiles://${this.pmtilesUrl}`
      })

      // use the first layer found
      this.map.addLayer({
        id: "pmtiles-layer",
        type: "fill",
        source: "pmtiles-source",
        "source-layer": metadata.vector_layers[0].id,
        paint: {
          "fill-color": "steelblue",
          "fill-opacity": 0.75
        }
      })

      // Hover tooltip popup
      const popup = new maplibregl.Popup({
        closeButton: false,
        closeOnClick: false
      })

      const interactiveLayers = ["pmtiles-layer"]

      // Show a tooltip on mouse move
      this.map.on("mousemove", e => {
        const features = this.map.queryRenderedFeatures(e.point, {
          layers: interactiveLayers
        })
        if (features.length > 0) {
          this.map.getCanvas().style.cursor = "pointer"
          const feature = features[0]

          const label =
            feature.properties.name ||
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

      this.map.on("click", "pmtiles-layer", e => {
        const feature = e.features[0]
        this.highlightFeature(feature)
        this.inspection(feature.properties)
      })
    })
  }

  inspection(properties) {
    const data = { ...properties }
    this.openSidebarWithContent(this.info(data))
  }

  info(data) {
    let output = '<div class="pmtiles-info"><div><dl>'

    // Display all properties from the feature
    Object.entries(data).forEach(([key, value]) => {
      if (value !== null && value !== undefined && value !== "") {
        output += `<dt>${key}</dt><dd>${value}</dd>`
      }
    })

    return output + "</dl></div></div>"
  }
}
