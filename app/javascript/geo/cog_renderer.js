import "deck-gl-web"

export class CogRenderer {
  constructor(map, cogUrl) {
    this.map = map
    this.cogUrl = cogUrl
    const { DeckMapbox, DeckGlGeotiff, Geotiff } = window.GeoAssets
    // Set up Deck.gl overlay for raster rendering; render it underneath the
    // MapLibre layers so that the symbology is not obscured
    this.deckOverlay = new DeckMapbox.MapboxOverlay({ interleaved: true })
    this.cogLayer = DeckGlGeotiff.COGLayer
    this.DecoderPool = Geotiff.DecoderPool
    this.map.addControl(this.deckOverlay)
  }

  // Render a Cloud Optimized GeoTIFF (COG) using Deck.gl raster layer
  render() {
    const deckLayer = new this.cogLayer({
      id: "cog-deck-layer",
      geotiff: this.cogUrl,
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
    this.deckOverlay.setProps({
      layers: [deckLayer]
    })
  }
}
