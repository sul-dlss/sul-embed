// Adopts the Mapbox opacity control into a Leaflet plugin
import L from "leaflet";

!function(global) {
  'use strict';

  L.Control.LayerOpacity = L.Control.extend({
    initialize: function(layer) {
      var options = { position: 'topleft' };

      // check if layer is actually a layer group
      if (typeof layer.getLayers !== 'undefined') {
        const layers = layer.getLayers();
        // Check if geoJSON. Layer control is different between geoJSON and WMS layer
        this.geoJSON = layers[0].customProperty.geoJSON;

        // add first layer from layer group to options
        options.layer = layers[0];
        options.layers = layers;
      } else {

        // add layer to options
        options.layer = layer;
        options.layers = [layer];
      }

      L.Util.setOptions(this, options);
    },

    onAdd: function(map) {
      var _this = this;
      L.DomEvent.on(map, 'layeradd', function(e) {
        if (e.layer.customProperty && e.layer.customProperty.addToOpacitySlider){
          _this.options.layers.push(e.layer)
        }
      });

      L.DomEvent.on(map, 'layerremove', function(e) {
        if (e.layer.customProperty && e.layer.customProperty.addToOpacitySlider){
          const index = _this.options.layers.indexOf(e.layer);
          if (index) { _this.options.layers.splice(index, 1)}
        }
      });
      var container = L.DomUtil.create('div', 'opacity-control unselectable'),
        controlArea = L.DomUtil.create('div', 'opacity-area', container),
        handle = L.DomUtil.create('div', 'opacity-handle', container),
        handleArrowUp = L.DomUtil.create('div', 'opacity-arrow-up', handle),
        handleText = L.DomUtil.create('div', 'opacity-text', handle),
        handleArrowDown = L.DomUtil.create('div', 'opacity-arrow-down', handle),
        bottom = L.DomUtil.create('div', 'opacity-bottom', container);

      L.DomEvent.stopPropagation(container);
      L.DomEvent.disableClickPropagation(container);

      this.setListeners(handle, bottom, handleText);
      const opacity = this.geoJSON ? this.options.layer.options.fillOpacity : this.options.layer.options.opacity;
      const opacityPercentage = parseInt(opacity * 100);
      handle.style.top = `calc(100% - ${opacityPercentage}% - 12px)`;
      bottom.style.top = `calc(100% - ${opacityPercentage}%)`;
      bottom.style.height = `${opacityPercentage}%`;
      handle.setAttribute("tabindex", "0")
      handleText.innerHTML = opacityPercentage + '%';
      return container;
    },

    updateMapOpacity: function(opacity) {
      this.options.layers.forEach((layer) => this.layerOpacity(layer, opacity))
    },

    layerOpacity: function(layer, opacity) {
      try {
        layer.setStyle({'fillOpacity': opacity, "opacity": opacity})
      } catch {
        try {
          layer.setOpacity(opacity);
        } catch {
          console.log(layer)
        }
      }
    },

    setListeners: function(handle, bottom, handleText) {
      var _this = this,
        start = false,
        startTop;
      L.DomEvent.on(document, 'mousemove', function(e) {
        if (!start) return;
        var percentInverse = Math.max(0, Math.min(200, startTop + parseInt(e.clientY, 10) - start)) / 2;
        handle.style.top = ((percentInverse * 2) - 13) + 'px';
        handleText.innerHTML = Math.round((1 - (percentInverse / 100)) * 100) + '%';
        bottom.style.height = Math.max(0, (((100 - percentInverse) * 2) - 13)) + 'px';
        bottom.style.top = Math.min(200, (percentInverse * 2) + 13) + 'px';
        _this.updateMapOpacity((1 - (percentInverse / 100)))
      });

      L.DomEvent.on(handle, 'keydown', function(e) {
        const opacity = _this.geoJSON ? _this.options.layer.style.fillOpacity : _this.options.layer.options.opacity;
        const step = 1;
        var newOpacity;
        if (e.key == 'ArrowDown'){
          newOpacity = opacity * 100 - step;
        } else if (e.key == 'ArrowUp') {
          newOpacity = opacity * 100 + step;
        } else {
          return;
        }
        if (newOpacity > 100 || newOpacity < 0) { return; }
        newOpacity = Math.round(newOpacity)
        handle.style.top = `calc(100% - ${newOpacity}% - 12px)`;
        handleText.innerHTML = newOpacity + "%";
        bottom.style.height = newOpacity + "%";
        bottom.style.top = `calc(100% - ${newOpacity}%)`;
        _this.updateMapOpacity(newOpacity / 100)
      });

      L.DomEvent.on(handle, 'mousedown', function(e) {
        start = parseInt(e.clientY, 10);
        startTop = handle.offsetTop - 12;
        return false;
      });

      L.DomEvent.on(document, 'mouseup', function(e) {
        start = null;
      });
    }
  });
}(this);