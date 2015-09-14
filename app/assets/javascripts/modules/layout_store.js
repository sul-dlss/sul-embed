/*global PubSub */
// Module handles LayoutStore using Flux architecture

(function(global) {
  'use strict';
  var LayoutStore = function(options) {
    var _this = this;

    $.extend(true, _this, {
    }, options);

    _this.init();
    _this.listenForActions();
  };

  LayoutStore.prototype = {
    init: function() {
      var _this = this;
      _this.state({
        bottomPanelEnabled: true,
        bottomPanelOpen: true,
        modesAvailable: true,
        overviewPerspectiveAvailable: true
        // currentFocus: null,
        // downloadPanelVisible: true,
        // height: 200,
        // width: 200
      }, true);
    },
    listenForActions: function() {
      var _this = this;

      PubSub.subscribe('thumbSliderToggle', function() {
        _this.state({
          bottomPanelOpen: !_this.getState().bottomPanelOpen
        });
      });
      PubSub.subscribe('updateBottomPanel', function(_, status) {
        _this.state({
          bottomPanelEnabled: status
        });
      });
      PubSub.subscribe('disableModes', function() {
        _this.state({
          modesAvailable: false
        });
      });
      PubSub.subscribe('disableOverviewPerspective', function() {
        _this.state({
          overviewPerspectiveAvailable: false
        });
      });
    },
    state: function(state, initial) {
      var _this = this;

      if (!arguments.length) {
        return this.layoutState;
      }

      _this.layoutState = $.extend(_this.layoutState, state);

      if (!initial) {
        PubSub.publish('layoutStateUpdated');
      }

      return this.layoutState;
    },
    getState: function() {
      return this.state();
    }
  };

  global.LayoutStore = LayoutStore;

})(this);
