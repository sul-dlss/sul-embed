import './leaflet_opacity'
export default {
  isDefined: function (object) {
    return typeof object !== 'undefined';
  },
  init: function (options) {
    this.$el = jQuery('#sul-embed-geo-map');
    this.dataAttributes = this.$el.data();

    this.map = L.map('sul-embed-geo-map', options).fitBounds(this.dataAttributes.boundingBox);

    const attribution = `&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="http://carto.com/attributions">Carto</a>`
    L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png', {
      maxZoom: 19,
      attribution: attribution,
    }).addTo(this.map);
    this.highlightLayer = L.layerGroup().addTo(this.map);

    this.addVisualizationLayer();

    this.map.invalidateSize();
  },
  addVisualizationLayer: function () {
    const dataAttributes = this.dataAttributes;
    var hasWmsUrl = this.isDefined(dataAttributes.wmsUrl);
    var hasLayers = this.isDefined(dataAttributes.layers);
    var indexMapUrl = dataAttributes.indexMap;

    if (this.isDefined(indexMapUrl)) {
      // Index map viewer
      var geoJSONLayer;
      var _this = this;
      $.getJSON(indexMapUrl, function (data) {
        geoJSONLayer = L.geoJson(data,
          {
            style: function (feature) {
              return _this.availabilityStyle(feature.properties.available);
            },
            onEachFeature: function (feature, layer) {
              layer.customProperty = { geoJSON: true };
              // Add a hover label for the label property
              if (feature.properties.label !== null) {
                layer.bindTooltip(feature.properties.label);
              }
              // If it is available add clickable info
              if (feature.properties.available !== null) {
                layer.on('click', function (e) {
                  _this.highlightBox(this)
                  _this.indexMapInspection(e);
                });
              }
            },
            // For point index maps, use circle markers
            pointToLayer: function (feature, latlng) {
              return L.circleMarker(latlng);
            }
          }).addTo(_this.map);
        _this.map.fitBounds(geoJSONLayer.getBounds());
        _this.setupSidebar();
        _this.map.addControl(new L.Control.LayerOpacity(geoJSONLayer));
      });
    } else if (hasWmsUrl && hasLayers) {
      // Feature inspection for public layers
      this.layer = L.tileLayer.wms(dataAttributes.wmsUrl, {
        layers: dataAttributes.layers,
        format: 'image/png',
        transparent: true,
        opacity: .75,
        tiled: true
      })
      this.layer.addTo(this.map);
      this.setupSidebar();
      this.setupFeatureInspection();
      this.map.addControl(new L.Control.LayerOpacity(this.layer));
    } else {
      // Restricted layers
      L.rectangle(dataAttributes.boundingBox, { color: '#0000FF', weight: 4 })
        .addTo(this.map);
    }
  },
  availabilityStyle: function (availability) {
    var style = {
      radius: 4,
      weight: 1,
    };
    // Style the colors based on availability
    if (typeof (availability) === 'undefined') {
      return style; // default Leaflet style colorings
    }

    if (availability) {
      style.color = this.dataAttributes.geoViewerColors.available;
    } else {
      style.color = this.dataAttributes.geoViewerColors.unavailable;
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
  indexMapInspection: function (e) {
    var thumbDeferred = $.Deferred();
    var data = e.target.feature.properties;
    var _this = this;
    $.when(thumbDeferred).done(function () {
      _this.openSidebarWithContent(_this.indexMapInfo(data));
    });

    if (data.iiifUrl) {
      $.getJSON(data.iiifUrl, function (manifestResponse) {
        if (manifestResponse.thumbnail['@id'] !== null) {
          data.thumbnailUrl = manifestResponse.thumbnail['@id'];
          thumbDeferred.resolve();
        }
      });
    } else {
      thumbDeferred.resolve();
    }
  },
  setupFeatureInspection: function () {
    var _this = this;
    this.map.on('click', function (e) {
      // Return early if original target is not actually the map
      if (e.originalEvent.target.id !== 'sul-embed-geo-map') {
        return;
      }
      var wmsoptions = {
        LAYERS: _this.dataAttributes.layers,
        BBOX: _this.map.getBounds().toBBoxString(),
        WIDTH: Math.round($('#sul-embed-geo-map').width()),
        HEIGHT: Math.round($('#sul-embed-geo-map').height()),
        QUERY_LAYERS: _this.dataAttributes.layers,
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
        url: _this.dataAttributes.wmsUrl,
        data: wmsoptions,
        success: function (data) {
          // Handle the case where GeoServer returns a 200 but with an exception;
          if (data.exceptions && data.exceptions.length > 0) {
            return;
          }
          var html = '<dl class="inline-flex">';
          $.each(data.features, function (i, val) {
            Object.keys(val.properties).forEach(function (key) {
              html += L.Util.template('<dt>{k}</dt><dd>{v}</dd>', { k: key, v: val.properties[key] });
            });
          });
          html += '</dl>';
          _this.highlightBox(data);
          _this.openSidebarWithContent(html);
        }
      });
    });
  },

  highlightBox: function(data) {
    this.highlightLayer.clearLayers();
    if (!data._latlngs && !data.numberReturned) { return }
    var opacity = this.layer ? this.layer.options.opacity : data.options.fillOpacity ? data.options.fillOpacity : data.options.opacity;
    var geoJSON = false;
    var layer;
    var color = this.dataAttributes.geoViewerColors.selected;
    if (data._latlngs) {
      layer = L.polygon(data._latlngs, {
        color: color,
        weight: 2,
        layer: true,
        fillOpacity: opacity
      })
    } else {
      layer = L.geoJSON(data, {
        color: color,
        opacity: opacity,
        pointToLayer: function(feature, latlng) {
          return L.circleMarker(latlng, {
            radius: 8,
            fillColor: color,
            color: color,
            weight: 1,
            opacity: opacity,
            fillOpacity: opacity
          });
        }
      })
      geoJSON = true;
    }
    layer.customProperty = { 'addToOpacitySlider': true, geoJSON: geoJSON };
    layer.addTo(this.highlightLayer);
  },

  openSidebarWithContent: function (html) {
    this.$el
      .find('.sul-embed-geo-sidebar')
      .removeClass('collapsed')
      .find('.sul-embed-geo-sidebar-content')
      .html(html)
      .slideDown(400)
      .attr('aria-hidden', false);
  },
  geoSidebar: function () {
    return `<div class="sul-embed-geo-sidebar">
                  <div class="sul-embed-geo-sidebar-header">
                    <h3>Features</h3>
                    <i class="sul-i-arrow-up-8"></i>
                  </div>
                  <div class="sul-embed-geo-sidebar-content">Click the map to inspect features.</div>
                </div>`
  },
  setupSidebar: function () {
    L.control.custom({
      position: 'topright',
      content: this.geoSidebar(),
      classes: '',
      events: {
        click: function (e) {
          // When clicking outside of icon
          if (e.target.localName !== 'i') {
            return;
          }
          // When bar is not collapsed
          var $container = $(e.target).parent().parent();
          if (!$container.hasClass('collapsed')) {
            $('.sul-embed-geo-sidebar-content').slideUp(400, function () {
              $container.addClass('collapsed');
            }).attr('aria-hidden', true);
          } else {
            $('.sul-embed-geo-sidebar-content').slideDown(400, function () {
              $container.removeClass('collapsed');
            }).attr('aria-hidden', false);
          }
        }
      }
    }).addTo(this.map);
  },
};
