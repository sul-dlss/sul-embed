/* global createUV */
/* global UV */

(function( global ) {
  'use strict';

  var Module = (function() {
    var selector = '[data-behavior="uv"]';

    function setupUV(id, options) {
      var data = {
        iiifResourceUri: options.uvUri,
        configUri: options.uvConfig,
        root: options.uvRoot,
        embedded: true,
        canvasIndex: Number(options.canvasIndex),
        highlight: options.uvHighlight
      };

      createUV(id, data, new UV.URLDataProvider());
    }

    /*
    / This is used to detect if the viewer should try and show itself fullheight
    / by looking for the .sul-embed-fullheight class which should be present.
    / If it is present go and dynamically set the height for each element that
    / is needed. We need to do it this way because of how UV calculates its
    / heights everywhere.
    */
    function setCustomFullHeight(uvSelector) {
      var $uvSelector = $(uvSelector);
      var fullheight = $uvSelector.parents('.sul-embed-fullheight');
      // If the fullheight class is present, add custom height everywhere needed
      if (fullheight.length > 0) {
        fullheight.each(function() {
          $(this).css('height', 'calc(100vh - 20px)');
        });
        $uvSelector.parents('.sul-embed-body').each(function() {
          $(this).css('height', 'calc(100vh - 20px)');
        });
        $uvSelector.css('height', 'calc(100vh - 20px)');
      }
    }

    function setupEventListeners() {
      window.addEventListener('uvLoaded', function() {
        $(selector).each(function() {
          setCustomFullHeight(this);
          setupUV('#' + $(this).attr('id'), $(this).data());
        });
      }, false);
    }

    return {
      init: function() {
        setupEventListeners();
      }
    };
  })();

  global.UVViewer = Module;
})(this);
