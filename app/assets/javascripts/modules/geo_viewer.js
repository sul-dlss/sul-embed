
(function( global ) {
  'use strict';
  var Module = (function() {
    var dataAttributes;
    var map;
    
    var isDefined = function(object) {
       return typeof object !== 'undefined';
    };

    return {
      init: function() {
        dataAttributes = jQuery('#sul-embed-geo-map').data();

        map = L.map('sul-embed-geo-map').fitBounds(dataAttributes.boundingBox);

        L.tileLayer('https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png', {
          maxZoom: 19,
          attribution: '&copy; <a href="http://www.openstreetmap.org/copyrigh' +
            't">OpenStreetMap</a>, Tiles courtesy of <a href="http://hot.open' +
            'streetmap.org/" target="_blank">Humanitarian OpenStreetMap Team<' +
            '/a>',
        }).addTo(map);
        
        Module.addVisualizationLayer();
        map.invalidateSize();
      },
      addVisualizationLayer: function() {
        var hasWmsUrl = isDefined(dataAttributes.wmsUrl);
        var hasLayers = isDefined(dataAttributes.layers);

        if (hasWmsUrl && hasLayers) {
          L.tileLayer.wms(dataAttributes.wmsUrl, {
              layers: dataAttributes.layers,
              format: 'image/png',
              transparent: true,
              tiled: true
          }).addTo(map);
        } else {
          L.rectangle(dataAttributes.boundingBox, {color: '#0000FF', weight: 4})
            .addTo(map);
        }
      }
    };
  })();

  global.GeoViewer = Module;
})(this);
