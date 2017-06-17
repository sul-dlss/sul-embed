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
        root: options.uvRoot
      };

      createUV(id, data, new UV.URLDataProvider());
    }

    function setupEventListeners() {
      window.addEventListener('uvLoaded', function() {
        $(selector).each(function() {
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
