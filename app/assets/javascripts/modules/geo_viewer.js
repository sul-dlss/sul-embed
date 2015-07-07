
(function( global ) {
  'use strict';
  var Module = (function() {

    return {
      init: function() {
        var map = L.map('sul-embed-geo-map').setView([51.505, -0.09], 13);

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
        map.invalidateSize();
      }
    };
  })();

  global.GeoViewer = Module;
})(this);
