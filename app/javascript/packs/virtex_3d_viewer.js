'use strict';

import CommonViewerBehavior from '../src/modules/common_viewer_behavior.js';
import { EmbedThis } from '../src/modules/embed_this.js';
import { PopupPanels } from '../src/modules/popup_panels.js';
import Fullscreen from '../src/modules/fullscreen.js';
import Virtex3DViewer from '../src/modules/virtex_3d_viewer.js';

$(document).ready(function() {
  CommonViewerBehavior.initializeViewer(
    Virtex3DViewer.init
  );
  PopupPanels.init();
  EmbedThis.init();
  Fullscreen.init('.sul-embed-3d');
});
