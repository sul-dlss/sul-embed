import * as pmtiles from "pmtiles"

export class PmtilesRenderer {
  constructor(map, pmtilesUrl, openSidebarWithContent, highlightFeature, authToken) {
    this.map = map
    this.pmtilesUrl = pmtilesUrl
    this.openSidebarWithContent = openSidebarWithContent
    this.highlightFeature = highlightFeature
    this.authToken = authToken
  }

  render() {
    // add the PMTiles plugin to the maplibregl global.
    const protocol = new pmtiles.Protocol()
    maplibregl.addProtocol("pmtiles", protocol.tile)

    let source = this.pmtilesUrl
    if (this.authToken) {
      source = this.credentialedSource(this.pmtilesUrl)
    }
    const p = new pmtiles.PMTiles(source)

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

      const interactiveLayers = this.drawLayers(
        metadata.vector_layers.map(layer => layer.id)
      )

      // Hover tooltip popup
      const popup = new maplibregl.Popup({
        closeButton: false,
        closeOnClick: false
      })

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

      interactiveLayers.forEach(layer => {
        this.map.on("click", layer, e => {
          const feature = e.features[0]
          this.highlightFeature(feature)
          this.inspection(feature.properties)
        })
      })
    })
  }

  drawLayers(layers) {
    const ids = []
    layers.forEach((vectorLayer, i) => {
      this.map.addLayer({
        id: `pmtiles-fill-${i}`,
        type: "fill",
        source: "pmtiles-source",
        "source-layer": vectorLayer,
        paint: {
          "fill-color": this.colorForIdx(i),
          "fill-opacity": 0.75
        },
        filter: ["==", ["geometry-type"], "Polygon"]
      })

      this.map.addLayer({
        id: `pmtiles-line-${i}`,
        type: "line",
        source: "pmtiles-source",
        "source-layer": vectorLayer,
        paint: {
          "line-color": this.colorForIdx(i),
          "line-width": [
            "case",
            ["boolean", ["feature-state", "hover"], false],
            2,
            0.5
          ]
        },
        filter: ["==", ["geometry-type"], "LineString"]
      })

      this.map.addLayer({
        id: `pmtiles-circle-${i}`,
        type: "circle",
        source: "pmtiles-source",
        "source-layer": vectorLayer,
        paint: {
          "circle-color": this.colorForIdx(i),
          "circle-radius": ["interpolate", ["linear"], ["zoom"], 4, 2, 12, 4],
          "circle-opacity": 0.5,
          "circle-stroke-color": "white",
          "circle-stroke-width": [
            "case",
            ["boolean", ["feature-state", "hover"], false],
            3,
            0
          ]
        },
        filter: ["==", ["geometry-type"], "Point"]
      })
      ids.push(`pmtiles-circle-${i}`, `pmtiles-line-${i}`, `pmtiles-fill-${i}`)
    })
    return ids
  }

  colorForIdx(i) {
    const colors = ["steelblue", "tomato", "sandybrown", "palevioletred"]
    const color = colors[i % colors.length]
    return color
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

  // A pmtiles Source that sends cookies so restricted files are served directly
  // without a redirect to the (CORS-incompatible) /file/auth/ path
  credentialedSource(url) {
    return {
      getKey: () => url,
      getBytes: async (offset, length, signal) => {
        const resp = await fetch(url, {
          headers: { Range: `bytes=${offset}-${offset + length - 1}` },
          signal,
          credentials: "include"
        })
        return {
          data: await resp.arrayBuffer(),
          etag: resp.headers.get("ETag") || undefined,
          expires: resp.headers.get("Expires") || undefined,
          cacheControl: resp.headers.get("Cache-Control") || undefined
        }
      }
    }
  }
}
