(function( global ) {
  'use strict';
  const Module = (function() {
    let dataAttributes;
    let boundingBox;
    let map;
    let $el;

    const isDefined = function(object) {
       return typeof object !== 'undefined';
    };

    return {
      init: function(options) {
        const el = document.getElementById('sul-embed-geo-map')

        dataAttributes = el.dataset;
        // dataAttributes looks like this:
        // {
        //   "boundingBox": "[[\"-1.478794\", \"29.572742\"], [\"4.234077\", \"35.000308\"]]",
        //   "wmsUrl": "https://geowebservices.stanford.edu/geoserver/wms/",
        //   "layers": "druid:cz128vq0535"
        // }
        boundingBox = JSON.parse(dataAttributes.boundingBox)
        $el = jQuery(el);
        map = L.map('sul-embed-geo-map', options).fitBounds(boundingBox);

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
        var indexMapUrl = dataAttributes.indexMap;

        if (isDefined(indexMapUrl)) {
          // Index map viewer
          var geoJSONLayer;
          var _this = this;
          $.getJSON(indexMapUrl, function(data) {
            geoJSONLayer = L.geoJson(data,
              {
                style: function(feature) {
                  return _this.availabilityStyle(feature.properties.available);
                },
                onEachFeature: function(feature, layer) {
                  // Add a hover label for the label property
                  if (feature.properties.label !== null) {
                    layer.bindTooltip(feature.properties.label);
                  }
                  // If it is available add clickable info
                  if (feature.properties.available !== null) {
                    layer.on('click', function(e) {
                      _this.indexMapInspection(e);
                    });
                  }
                },
                // For point index maps, use circle markers
                pointToLayer: function (feature, latlng) {
                  return L.circleMarker(latlng);
                }
              }).addTo(map);
              map.fitBounds(geoJSONLayer.getBounds());
              Module.setupSidebar();
          });
        } else if (hasWmsUrl && hasLayers) {
          // Feature inspection for public layers
          L.tileLayer.wms(dataAttributes.wmsUrl, {
              layers: dataAttributes.layers,
              format: 'image/png',
              transparent: true,
              tiled: true
          }).addTo(map);
          Module.setupSidebar();
          Module.setupFeatureInspection();
        } else {
          // Restricted layers
          L.rectangle(boundingBox, {color: '#0000FF', weight: 4})
            .addTo(map);
        }
      },
      availabilityStyle: function(availability) {
        var style = {
          radius: 4,
          weight: 1,
        };
        // Style the colors based on availability
        if (typeof(availability) === 'undefined') {
          return style; // default Leaflet style colorings
        }

        if (availability) {
          style.color = '#1eb300';
        } else {
          style.color = '#b3001e';
        }
        return style;
      },
      indexMapInspection: function(e) {
        var thumbDeferred = $.Deferred();
        var data = e.target.feature.properties;
        var _this = this;
        $.when(thumbDeferred).done(function() {
          const template = require('../templates/index_map_info.hbs');
          _this.openSidebarWithContent(template(data));
        });

        if (data.iiifUrl) {
          $.getJSON(data.iiifUrl, function(manifestResponse) {
            if (manifestResponse.thumbnail['@id'] !== null) {
              data.thumbnailUrl = manifestResponse.thumbnail['@id'];
              thumbDeferred.resolve();
            }
          });
        } else {
          thumbDeferred.resolve();
        }
      },
      setupFeatureInspection: function() {
        var _this = this;
        map.on('click', function(e) {
          // Return early if original target is not actually the map
          if (e.originalEvent.target.id !== 'sul-embed-geo-map') {
            return;
          }
          var wmsoptions = {
            LAYERS: dataAttributes.layers,
            BBOX: map.getBounds().toBBoxString(),
            WIDTH: Math.round($('#sul-embed-geo-map').width()),
            HEIGHT: Math.round($('#sul-embed-geo-map').height()),
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
              _this.openSidebarWithContent(html);
            }
          });
        });
      },
      openSidebarWithContent: function(html) {
        $el
          .find('.sul-embed-geo-sidebar')
          .removeClass('collapsed')
          .find('.sul-embed-geo-sidebar-content')
          .html(html)
          .slideDown(400)
          .css({'height': map.getSize().y - 90})
          .attr('aria-hidden', false);
      },
      setupSidebar: function() {
        const template = require('../templates/geo_sidebar.hbs');
        L.control.custom({
          position: 'topright',
          content: template(),
          classes: '',
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

  // Basic support of CommonJS module for import into test
  if (typeof exports === "object") {
    module.exports = Module;
  }

  global.GeoViewer = Module;
})(this || {});
