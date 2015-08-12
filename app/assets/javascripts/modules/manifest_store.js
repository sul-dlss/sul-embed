/*global PubSub */
// Module handles ManifestStore using Flux architecture

(function(global) {
  'use strict';
  var ManifestStore = function(options) {
    var _this = this;

    $.extend(true, _this, {
    }, options);
    
    _this.init();
    _this.listenForActions();
  };
  
  ManifestStore.prototype = {
    init: function() {
      var _this = this;
      _this.state({
        manifest: null
      }, true);
    },
    listenForActions: function() {
      var _this = this;
      PubSub.subscribe('manifestDone', function(_, data) {
        _this.state({
          manifest: data
        });
      });
    },
    state: function(state, initial) {
      if (!arguments.length) {
        return this.manifestState;
      }

      this.manifestState = state;

      if (!initial) {
        PubSub.publish('manifestStateUpdated');  
      }

      return this.manifestState;      
    }
  };

  global.ManifestStore = ManifestStore;

})(this);
