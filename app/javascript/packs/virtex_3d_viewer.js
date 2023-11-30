'use strict';

import EmbedThis from '../src/modules/embed_this';
import PopupPanels from '../src/modules/popup_panels';
import Fullscreen from '../src/modules/fullscreen.js';
import Virtex3DViewer from '../src/modules/virtex_3d_viewer.js';

$(document).ready(function() {
  document.getElementById('sul-embed-object').hidden = false
  Virtex3DViewer.init()
  PopupPanels.init();
  EmbedThis.init();
  Fullscreen.init('.sul-embed-3d');
});
