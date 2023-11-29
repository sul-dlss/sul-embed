'use strict';

import EmbedThis from '../src/modules/embed_this';
import PopupPanels from '../src/modules/popup_panels';
import Fullscreen from '../src/modules/fullscreen.js';
import ModelViewer from '../src/modules/model_viewer.js';

import '@google/model-viewer/dist/model-viewer-module.js';

$(document).ready(function() {
  document.getElementById('sul-embed-object').hidden = false
  ModelViewer.init()
  PopupPanels.init();
  EmbedThis.init();
  Fullscreen.init('.sul-embed-3d');
});
