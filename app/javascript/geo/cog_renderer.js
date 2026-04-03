import { MapboxOverlay as DeckOverlay } from '@deck.gl/mapbox';
import { COGLayer } from '@developmentseed/deck.gl-geotiff'; 
// import { DecoderPool } from '@developmentseed/geotiff'

export class CogRenderer {
  constructor(map, cogUrl) {
    this.map = map
    this.cogUrl = cogUrl

    // Set up Deck.gl overlay for raster rendering; render it underneath the
    // MapLibre layers so that the symbology is not obscured
    this.deckOverlay = new DeckOverlay({ interleaved: true })
    this.map.addControl(this.deckOverlay)
  }

  // Render a Cloud Optimized GeoTIFF (COG) using Deck.gl raster layer
  render() {
    const deckLayer = new COGLayer({
      id: 'cog-deck-layer',
      geotiff: this.cogUrl,
      // Disable the web worker decoder pool; this appears to cause errors because
      // it can't find /worker.js?
      // See: https://developmentseed.org/deck.gl-raster/api/geotiff/type-aliases/DecoderPoolOptions/
      // See also: https://github.com/developmentseed/deck.gl-raster/issues/364
      // pool: new DecoderPool({
      //   createWorker: null
      // })
    });
    this.deckOverlay.setProps({
      layers: [deckLayer]
    });
  }
}
