import { Controller } from "@hotwired/stimulus"
import "leaflet"
import "Leaflet.Control.Custom"
import 'geo/leaflet_opacity'

export default class extends Controller {
  connect() {
    const options = null
    this.el = document.getElementById('sul-embed-geo-map')
    this.dataAttributes = this.el.dataset
    this.map = L.map('sul-embed-geo-map', options).fitBounds(JSON.parse(this.dataAttributes.boundingBox))

    const resizeObserver = new ResizeObserver(() => this.map.invalidateSize())
    resizeObserver.observe(this.el)

    const attribution = `&copy <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy <a href="http://carto.com/attributions">Carto</a>`
    L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}@2x.png', {
      maxZoom: 19,
      noWrap: true,
      bounds: [[-90, -180],[90, 180]],
      attribution: attribution,
    }).addTo(this.map)
    this.highlightLayer = L.layerGroup().addTo(this.map)

    this.addVisualizationLayer()

    this.map.invalidateSize()
  }

  isDefined(obj) {
    return typeof obj !== 'undefined'
  }

  show(evt) {
    if (this.replacementLayer) {
      this.map.removeLayer(this.replacementLayer)
      this.dataAttributes.wmsUrl = evt.detail.location
      this.addVisualizationLayer()
    }
  }

  addVisualizationLayer() {
    const dataAttributes = this.dataAttributes
    const hasWmsUrl = this.isDefined(dataAttributes.wmsUrl)
    const hasLayers = this.isDefined(dataAttributes.layers)
    const indexMapUrl = dataAttributes.indexMap

    if (this.isDefined(indexMapUrl)) {
      // Index map viewer
      const _this = this
      fetch(indexMapUrl)
        .then(response => response.json())
        .then(data => {
          const geoJSONLayer = L.geoJson(data, {
            style: function (feature) {
              return _this.availabilityStyle(feature.properties.available)
            },
            onEachFeature: function (feature, layer) {
              layer.customProperty = { geoJSON: true }
              // Add a hover label for the label property
              if (feature.properties.label !== null) {
                layer.bindTooltip(feature.properties.label)
              }
              // If it is available add clickable info
              if (feature.properties.available !== null) {
                layer.on('click', function (e) {
                  _this.highlightBox(this)
                  _this.indexMapInspection(e)
                })
              }
            },
            // For point index maps, use circle markers
            pointToLayer: function (feature, latlng) {
              return L.circleMarker(latlng)
            }
          }).addTo(_this.map)
          _this.map.fitBounds(geoJSONLayer.getBounds())
          _this.setupSidebar()
          _this.map.addControl(new L.Control.LayerOpacity(geoJSONLayer))
        })
    } else if (hasWmsUrl && hasLayers) {
      // Feature inspection for public layers
      this.layer = L.tileLayer.wms(dataAttributes.wmsUrl, {
        layers: dataAttributes.layers,
        format: 'image/png',
        transparent: true,
        opacity: .75,
        tiled: true,
        noWrap: true,
        bounds: [[-90, -180],[90, 180]]
      })
      this.layer.addTo(this.map)
      this.setupSidebar()
      this.setupFeatureInspection()
      this.map.addControl(new L.Control.LayerOpacity(this.layer))
    } else {
      // Restricted layers
      this.replacementLayer = L.rectangle(JSON.parse(this.dataAttributes.boundingBox), { color: '#0000FF', weight: 4 })
      this.replacementLayer.addTo(this.map)
    }
  }

  availabilityStyle(availability) {
    const style = {
      radius: 4,
      weight: 1,
    }
    // Style the colors based on availability
    if (typeof (availability) === 'undefined') {
      return style // default Leaflet style colorings
    }

    const colors = JSON.parse(this.dataAttributes.geoViewerColors)
    if (availability) {
      style.color = colors.available
    } else {
      style.color = colors.unavailable
    }
    return style
  }

  indexMapInfo(data) {
    let output = '<div class="index-map-info">'
    if (data.title) {
      output += `<h3>${data.title}</h3>`
    }
    output += "<div>"
    if (data.thumbnailUrl) {
      output += `<img src="${data.thumbnailUrl}" style="max-width: 100%; height: auto" alt="">`
    }
    output += "<dl>"
    if (data.websiteUrl) {
      output += `<a target="_blank" href="${data.websiteUrl}" rel="noopener noreferrer">View this map</a>`
    }
    if (data.downloadUrl) {
      output += `<dt>Download</dt><dd><a target="_blank" href="${data.downloadUrl}" rel="noopener noreferrer">${data.downloadUrl}</a></dd>`
    }
    if (data.label) {
      output += `<dt>Label</dt><dd>${data.label}</dd>`
    }
    if (data.note) {
      output += `<dt>Note</dt><dd>${data.note}</dd>`
    }
    return output + "</dl></div></div>"
  }

  indexMapInspection(e) {
    const data = e.target.feature.properties
    const _this = this

    const thumbPromise = new Promise(resolve => {
      if (data.iiifUrl) {
        fetch(data.iiifUrl)
          .then(response => response.json())
          .then(manifestResponse => {
            if (manifestResponse.thumbnail['@id'] !== null) {
              data.thumbnailUrl = manifestResponse.thumbnail['@id']
            }
            resolve()
          })
      } else {
        resolve()
      }
    })

    thumbPromise.then(() => {
      _this.openSidebarWithContent(_this.indexMapInfo(data))
    })
  }

  setupFeatureInspection() {
    const _this = this
    this.map.on('click', function (e) {
      // Return early if original target is not actually the map
      if (e.originalEvent.target.id !== 'sul-embed-geo-map') {
        return
      }

      const wmsoptions = new URLSearchParams({
        LAYERS: _this.dataAttributes.layers,
        BBOX: _this.map.getBounds().toBBoxString(),
        WIDTH: Math.round(_this.el.clientWidth),
        HEIGHT: Math.round(_this.el.clientHeight),
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
      })

      const url = new URL(_this.dataAttributes.wmsUrl)
      url.search += (url.search ? "&" : "") + wmsoptions.toString()

      fetch(url.toString())
      .then(response => response.json())
      .then(data => {
          // Handle the case where GeoServer returns a 200 but with an exception
          if (data.exceptions && data.exceptions.length > 0) {
            return
          }
          let html = '<dl class="inline-flex" style="margin-top: 0">'
          data.features.forEach(function (val) {
            Object.keys(val.properties).forEach(function (key) {
              html += L.Util.template('<dt>{k}</dt><dd>{v}</dd>', { k: key, v: val.properties[key] })
            })
          })
          html += '</dl>'
          _this.highlightBox(data)
          _this.openSidebarWithContent(html)
      })
    })
  }

  highlightBox(data) {
    this.highlightLayer.clearLayers()

    if (!data._latlngs && !data.numberReturned) {
      return
    }

    const opacity = this.layer ? this.layer.options.opacity : data.options?.fillOpacity ? data.options.fillOpacity : data.options?.opacity

    let geoJSON = false
    let layer
    const color = JSON.parse(this.dataAttributes.geoViewerColors).selected

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
        pointToLayer: function (feature, latlng) {
          return L.circleMarker(latlng, {
            radius: 8,
            fillColor: color,
            color: color,
            weight: 1,
            opacity: opacity,
            fillOpacity: opacity
          })
        }
      })
      geoJSON = true
    }
    layer.customProperty = { 'addToOpacitySlider': true, geoJSON: geoJSON }
    layer.addTo(this.highlightLayer)
  }

  openSidebarWithContent(html) {
    const sidebar = this.el.querySelector('.sul-embed-geo-sidebar')
    const button = sidebar.querySelector('button')
    const sidebarContent = sidebar.querySelector('.sul-embed-geo-sidebar-content')
    button.setAttribute('aria-expanded', 'true')

    sidebarContent.classList.add('show')
    sidebarContent.innerHTML = html
    sidebarContent.style.maxHeight = (this.map.getSize().y - 90) + 'px'
    sidebarContent.setAttribute('aria-hidden', false)
  }

  geoSidebar() {
    return `<div class="sul-embed-geo-sidebar">
                  <div class="sul-embed-geo-sidebar-header">
                    <h3>Features</h3>
                    <button aria-label="expand/collapse" aria-expanded="true" aria-controls="sidebarContent">
                      <svg class="MuiSvgIcon-root KeyboardArrowUpSharp" focusable="false" aria-hidden="true" viewBox="0 0 24 24"><path d="M7.41 15.41 12 10.83l4.59 4.58L18 14l-6-6-6 6z"></path></svg>
                    </button>
                  </div>
                  <div id="sidebarContent" class="sul-embed-geo-sidebar-content show">Click the map to inspect features.</div>
                </div>`
  }

  setupSidebar() {
    L.control.custom({
      position: 'topright',
      content: this.geoSidebar(),
      classes: '',
      events: {
        click: function (e) {
          const button = e.target.closest('button')

          if (!button) {
            return
          }
          const containerId = button.getAttribute('aria-controls')
          const container = document.getElementById(containerId)
          if (button.getAttribute('aria-expanded') === 'true') {
            container.classList.remove('show')
            button.setAttribute('aria-expanded', 'false')
          } else {
            container.classList.add('show')
            button.setAttribute('aria-expanded', 'true')
          }
        }.bind(this) // Bind 'this' to access the map instance
      }
    }).addTo(this.map)
  }
}
