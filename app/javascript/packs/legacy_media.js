'use strict';

import EmbedThis from '../src/modules/embed_this';
import PopupPanels from '../src/modules/popup_panels';
import LegacyMediaViewer from '../src/modules/legacy_media_viewer.js';

$(document).ready(function() {
  document.getElementById('sul-embed-object').hidden = false
  PopupPanels.init();
  EmbedThis.init();
  LegacyMediaViewer.init();
});
