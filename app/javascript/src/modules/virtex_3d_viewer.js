'use strict';

import * as THREE from 'three';
import { MTLLoader } from 'three/examples/jsm/loaders/MTLLoader';
import { OBJLoader } from 'three/examples/jsm/loaders/OBJLoader';
import { WEBGL } from 'three/examples/jsm/WebGL';
import { Viewport } from 'virtex3d';

export default {
  // Init is passed as a callback (since it needs to execute after the
  // viewer is shown and there is available width to calculate canvas size)
  // That means "this" does not end being the right thing and we need to encapsulate the functionality here
  init: function() {
    global.THREE = {
      OBJLoader: OBJLoader,
      MTLLoader: MTLLoader,
      ...THREE
    };

    // Virtex uses a global Detector.  Three refactored this into the WEBGL library (and changed the API)
    // This is compatibility layer between what Vitex expects from the old Detector to the new WEBGL library.
    global.Detector = {
      webgl: WEBGL.isWebGLAvailable(),
      addGetWebGLMessage: WEBGL.getErrorMessage,
    };

    var viewer = $('#virtex-3d-viewer');
    var viewport = new Viewport({
      target: viewer[0],
      data: {
          file: viewer.data('three-dimensional-file'),
          fullscreenEnabled: true,
          showStats: false,
      }
    });

    viewer.prev('.buttons').find('.zoom-in').on('click', function(e) {
      e.preventDefault();
      viewport.zoomIn();
    });

    viewer.prev('.buttons').find('.zoom-out').on('click', function(e) {
        e.preventDefault();
        viewport.zoomOut();
    });
  },
};
