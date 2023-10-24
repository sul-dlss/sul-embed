
import { CssInjection } from '../src/modules/css_injection';
import { EmbedThis } from '../src/modules/embed_this';
import { PopupPanels } from '../src/modules/popup_panels';
import GeoViewer from '../src/modules/geo_viewer';
import CommonViewerBehavior from '../src/modules/common_viewer_behavior';

import 'leaflet';
import '../../../vendor/assets/javascripts/Leaflet.Control.Custom';

document.addEventListener('DOMContentLoaded', () => {
  CssInjection.injectFontIcons();
  CssInjection.appendToHead();
  CommonViewerBehavior.initializeViewer(GeoViewer.init);
  PopupPanels.init();
  EmbedThis.init();
})