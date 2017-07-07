/*global CssInjection */

import 'modules/css_injection'
import 'vendor/tooltip'
import 'modules/common_viewer_behavior'
import 'modules/popup_panels'
import 'modules/embed_this'
import 'leaflet'
import 'modules/geo_viewer'

CssInjection.injectFontIcons();
CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer(GeoViewer.init);
PopupPanels.init();
EmbedThis.init();
