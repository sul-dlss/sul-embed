/*global PubSub, manifestor */
// Module handles core data concerning
// the state of the openseadragon canvas
// using Flux-esque architecture.

(function(global) {
  'use strict';
  var CanvasStore = function(options) {
    var _this = this,
        manifestorInstance = manifestor({
          manifest: options.manifest,
          container: $('#sul-embed-image-x'),
          perspective: 'overview',
          frameClass: 'sul-embed-image-x-frame',
          canvasClass: 'sul-embed-image-x-canvas',
          labelClass: 'sul-embed-image-x-frame-label',
          stateUpdateCallback: function() {
            PubSub.publish('canvasStateUpdated');
          }
        });

    $.extend(true, _this, manifestorInstance);

    _this.listenForActions();
  };

  CanvasStore.prototype = {
    listenForActions: function() {
      var _this = this;
      PubSub.subscribe('currentImageUpdated', function(_, canvasId) {
        _this.selectCanvas(canvasId);
      });
      PubSub.subscribe('updateMode', function(_, newMode) {
        _this.selectViewingMode(newMode);
      });
      PubSub.subscribe('updatePerspective', function(_, newPerspective) {
        _this.selectPerspective(newPerspective);
      });
      PubSub.subscribe('selectPreviousCanvas', function(_, eventData) {
        _this.selectPreviousCanvas();
      });
      PubSub.subscribe('selectNextCanvas', function(_, eventData) {
        _this.selectNextCanvas();
      });
    }
  };

  global.CanvasStore = CanvasStore;

})(this);
