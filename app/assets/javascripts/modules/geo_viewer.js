
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

        L.tileLayer(
            'https://otile{s}-s.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.png', {
              attribution: '&copy; <a href="http://openstreetmap.org">OpenStr' +
                'eetMap</a> contributors, Tiles Courtesy of <a href="http://w' +
                'ww.mapquest.com/" target="_blank">MapQuest</a> <img src="//d' +
                'eveloper.mapquest.com/content/osm/mq_logo.png" alt="">',
              maxZoom: 18,
              worldCopyJump: true,
              subdomains: '1234'
            }
        ).addTo(map);
        
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
