import 'leaflet'

export default class GeoViewer {
  constructor() {
    this.dataAttributes = null;
    this.map = null;
  }

  isDefined(object) {
    return typeof object !== 'undefined';
  }

  init() {
    this.dataAttributes = jQuery('#sul-embed-geo-map').data();

    this.map = L.map('sul-embed-geo-map').fitBounds(this.dataAttributes.boundingBox);

    L.tileLayer('https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '&copy; <a href="http://www.openstreetmap.org/copyrigh' +
        't">OpenStreetMap</a>, Tiles courtesy of <a href="http://hot.open' +
        'streetmap.org/" target="_blank" rel="noopener noreferrer">Humanitarian OpenStreetMap Team<' +
        '/a>',
    }).addTo(this.map);

    this.addVisualizationLayer();
    this.map.invalidateSize();
  }
  addVisualizationLayer() {
    var hasWmsUrl = this.isDefined(this.dataAttributes.wmsUrl);
    var hasLayers = this.isDefined(this.dataAttributes.layers);

    if (hasWmsUrl && hasLayers) {
      L.tileLayer.wms(this.dataAttributes.wmsUrl, {
          layers: this.dataAttributes.layers,
          format: 'image/png',
          transparent: true,
          tiled: true
      }).addTo(this.map);
    } else {
      L.rectangle(this.dataAttributes.boundingBox, {color: '#0000FF', weight: 4})
        .addTo(this.map);
    }
  }
}
