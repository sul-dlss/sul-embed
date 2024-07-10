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
      init: function(options) {
        $el = jQuery('#sul-embed-geo-map');
        dataAttributes = $el.data();

        map = L.map('sul-embed-geo-map', options).fitBounds(dataAttributes.boundingBox);

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
          L.rectangle(dataAttributes.boundingBox, {color: '#0000FF', weight: 4})
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
      indexMapInfo(data) {
        let output = '<div class="index-map-info">'
        if (data.title)
          output = output.concat(`<h3>${data.title}</h3>`)
        output = output.concat("<div>")
        if (data.thumbnailUrl)
          output = output.concat(`<img src="${data.thumbnailUrl}" style="max-width: 100%; height: auto;" alt="">`)        
        output = output.concat("<dl>")
        if (data.websiteUrl)
          output = output.concat(`<a target="_blank" href="${data.websiteUrl}">View this map</a>`)
        if (data.downloadUrl)
          output = output.concat(`<dt>Download</dt><dd><a target="_blank" href="${data.downloadUrl}">${data.downloadUrl}</a></dd>`)
        if (data.recordIdentifier)
          output = output.concat(`<dt>Record Identifier</dt><dd><a target="_blank" href="${data.recordIdentifier}">${data.recordIdentifier}</a></dd>`)
        if (data.label)
          output = output.concat(`<dt>Label</dt><dd>${data.label}</dd>`)   
        if (data.note)
          output = output.concat(`<dt>Note</dt><dd>${data.note}</dd>`)   
        return output.concat("</dl></div></div>")
      },
      indexMapInspection: function(e) {
        var thumbDeferred = $.Deferred();
        var data = e.target.feature.properties;
        var _this = this;
        $.when(thumbDeferred).done(function() {
          _this.openSidebarWithContent(_this.indexMapInfo(data));
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
      geoSidebar: function() {
        return `<div class="sul-embed-geo-sidebar">
                  <div class="sul-embed-geo-sidebar-header">
                    <h3>Features</h3>
                    <i class="sul-i-arrow-up-8"></i>
                  </div>
                  <div class="sul-embed-geo-sidebar-content">Click the map to inspect features.</div>
                </div>`
      },
      setupSidebar: function() {
        L.control.custom({
          position: 'topright',
          content: this.geoSidebar(),
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
