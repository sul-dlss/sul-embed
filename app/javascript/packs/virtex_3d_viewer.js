'use strict';

import { CssInjection } from '../../assets/javascripts/modules/css_injection.js';
import { CommonViewerBehavior } from '../../assets/javascripts/modules/common_viewer_behavior.js';
import { EmbedThis } from '../../assets/javascripts/modules/embed_this.js';
import { PopupPanels } from '../../assets/javascripts/modules/popup_panels.js';
import Fullscreen from '../../assets/javascripts/modules/fullscreen.js';
import Virtex3DViewer from '../../assets/javascripts/modules/virtex_3d_viewer.js';

$(document).ready(function() {
  CssInjection.injectFontIcons();
  CssInjection.appendToHead();
  CommonViewerBehavior.initializeViewer(
    Virtex3DViewer.init
  );
  PopupPanels.init();
  EmbedThis.init();
  Fullscreen.init('.sul-embed-3d');
});
