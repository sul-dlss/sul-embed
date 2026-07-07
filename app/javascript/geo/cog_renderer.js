import "deck-gl-web"

export class CredentialedHttpSource {
  constructor(url) {
    this.type = "http"
    this.url = new URL(url, document.baseURI)
  }

  head() {
    this._head ||= fetch(this.url, {
      method: "HEAD",
      credentials: "include"
    }).then(response => {
      if (!response.ok) throw new Error(`Failed to HEAD ${this.url.href}: ${response.status}`)

      this.metadata = this.metadataFrom(response)
      return this.metadata
    })

    return this._head
  }

  async fetch(offset, length, options = {}) {
    const response = await fetch(this.url, {
      headers: { Range: `bytes=${offset}-${offset + length - 1}` },
      signal: options.signal,
      credentials: "include"
    })

    if (!response.ok) throw new Error(`Failed to fetch ${this.url.href}: ${response.status}`)

    this.metadata ||= this.metadataFrom(response)
    return response.arrayBuffer()
  }

  metadataFrom(response) {
    const metadata = {}
    const contentLength = response.headers.get("content-length")
    const contentRange = response.headers.get("content-range")

    if (contentLength) metadata.size = parseInt(contentLength, 10)
    if (contentRange) metadata.size = parseInt(contentRange.split("/").pop(), 10)

    metadata.eTag = response.headers.get("etag") || undefined
    metadata.contentType = response.headers.get("content-type") || undefined
    metadata.contentDisposition = response.headers.get("content-disposition") || undefined
    metadata.cacheControl = response.headers.get("cache-control") || undefined
    metadata.contentEncoding = response.headers.get("content-encoding") || undefined

    return metadata
  }
}

export class CogRenderer {
  constructor(map, cogUrl, addOpacityControl, authToken) {
    this.map = map
    this.cogUrl = cogUrl
    this.authToken = authToken
    const { DeckMapbox, DeckGlGeotiff, Geotiff } = window.GeoAssets
    // Set up Deck.gl overlay for raster rendering; render it underneath the
    // MapLibre layers so that the symbology is not obscured
    this.deckOverlay = new DeckMapbox.MapboxOverlay({ interleaved: true })
    this.cogLayer = DeckGlGeotiff.COGLayer
    this.DecoderPool = Geotiff.DecoderPool
    this.GeoTIFF = Geotiff.GeoTIFF
    this.map.addControl(this.deckOverlay)
    this.addOpacityControl = addOpacityControl
  }

  // Render a Cloud Optimized GeoTIFF (COG) using Deck.gl raster layer
  render() {
    const id = "cog-deck-layer"
    const initialOpacity = 1.0

    const buildLayer = opacity =>
      new this.cogLayer({
        id,
        opacity,
        geotiff: this.geotiffSource(),
        onGeoTIFFLoad: (_, { geographicBounds }) => {
          this.map.fitBounds(
            [
              [geographicBounds["west"], geographicBounds["south"]],
              [geographicBounds["east"], geographicBounds["north"]]
            ],
            { padding: 20 }
          )
        },
        // Disable the web worker decoder pool; this appears to cause errors because
        // it can't find /worker.js?
        // See: https://github.com/developmentseed/deck.gl-raster/blob/d3ab42a2f3e8d18d35443097136ed7f8056dabf0/packages/geotiff/package.json#L15
        // See: https://developmentseed.org/deck.gl-raster/api/geotiff/type-aliases/DecoderPoolOptions/
        // See also: https://github.com/developmentseed/deck.gl-raster/issues/364
        pool: new this.DecoderPool({
          createWorker: null
        })
      })

    this.deckOverlay.setProps({ layers: [buildLayer(initialOpacity)] })

    if (this.addOpacityControl) {
      this.addOpacityControl(
        opacity => this.deckOverlay.setProps({ layers: [buildLayer(opacity)] }),
        initialOpacity
      )
    }
  }

  geotiffSource() {
    if (!this.authToken) return this.cogUrl

    if (!this._geotiffSource) {
      const source = new CredentialedHttpSource(this.cogUrl)
      this._geotiffSource = this.GeoTIFF.open({
        dataSource: source,
        headerSource: source
      })
    }

    return this._geotiffSource
  }
}
