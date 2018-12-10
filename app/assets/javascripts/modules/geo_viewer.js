
(function( global ) {
  'use strict';
  var Module = (function() {
    var dataAttributes;
    var map;
    var $el;

    var isDefined = function(object) {
       return typeof object !== 'undefined';
    };

    return {
      init: function() {
        $el = jQuery('#sul-embed-geo-map');
        dataAttributes = $el.data();

        map = L.map('sul-embed-geo-map').fitBounds(dataAttributes.boundingBox);

        L.tileLayer('https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png', {
          maxZoom: 19,
          attribution: '&copy; <a href="http://www.openstreetmap.org/copyrigh' +
            't">OpenStreetMap</a>, Tiles courtesy of <a href="http://hot.open' +
            'streetmap.org/" target="_blank" rel="noopener noreferrer">Humanitarian OpenStreetMap Team<' +
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
          Module.setupSidebar();
          Module.setupFeatureInspection();
        } else {
          L.rectangle(dataAttributes.boundingBox, {color: '#0000FF', weight: 4})
            .addTo(map);
        }
      },
      setupFeatureInspection: function() {
        map.on('click', function(e) {
          // Return early if original target is not actually the map
          if (e.originalEvent.target.id !== 'sul-embed-geo-map') {
            return;
          }
          var wmsoptions = {
            LAYERS: dataAttributes.layers,
            BBOX: map.getBounds().toBBoxString(),
            WIDTH: $('#sul-embed-geo-map').width(),
            HEIGHT: $('#sul-embed-geo-map').height(),
            QUERY_LAYERS: dataAttributes.layers,
            X: Math.round(e.containerPoint.x),
            Y: Math.round(e.containerPoint.y),
            SERVICE: 'WMS',
            VERSION: '1.1.1',
            REQUEST: 'GetFeatureInfo',
            STYLES: '',
            SRS: 'EPSG:4326',
            EXCEPTIONS: 'application/json',
            INFO_FORMAT: 'application/json'
          };
          $.ajax({
            type: 'GET',
            url: dataAttributes.wmsUrl,
            data: wmsoptions,
            success: function(data) {
              // Handle the case where GeoServer returns a 200 but with an exception;
              if (data.exceptions && data.exceptions.length > 0) {
                return;
              }
              var html = '<dl class="inline-flex">';
              $.each(data.features, function(i, val) {
                Object.keys(val.properties).forEach(function(key) {
                  html += L.Util.template('<dt>{k}</dt><dd>{v}</dd>', {k: key, v: val.properties[key]});
                });
              });
              html += '</dl>';
              $el
                .find('.sul-embed-geo-sidebar')
                .removeClass('collapsed')
                .find('.sul-embed-geo-sidebar-content')
                .html(html)
                .slideDown(400)
                .css({'height': map.getSize().y - 90})
                .attr('aria-hidden', false);
            }
          });
        });
      },
      setupSidebar: function() {
        var control = '<div class="sul-embed-geo-sidebar">' +
                        '<div class="sul-embed-geo-sidebar-header">' +
                          '<h3>Features</h3>' +
                          '<i class="sul-i-arrow-up-8"></i>' +
                        '</div>' +
                        '<div class="sul-embed-geo-sidebar-content">Click the map to inspect features.</div>' +
                      '</div>';
        L.control.custom({
          position: 'topright',
          content: control,
          classes: 'leaflet-bar',
          events: {
            click: function(e) {
              // When clicking outside of icon
              if (e.target.localName !== 'i') {
                return;
              }
              // When bar is not collapsed
              var $container = $(e.target).parent().parent();
              if (!$container.hasClass('collapsed')) {
                $('.sul-embed-geo-sidebar-content').slideUp(400, function() {
                  $container.addClass('collapsed');
                }).attr('aria-hidden', true);
              } else {
                $('.sul-embed-geo-sidebar-content').slideDown(400, function() {
                  $container.removeClass('collapsed');
                }).attr('aria-hidden', false);
              }
            }
          }
        }).addTo(map);
      },
    };
  })();

  global.GeoViewer = Module;
})(this);
