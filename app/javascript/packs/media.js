/*global CssInjection */

import 'modules/css_injection'
import 'modules/common_viewer_behavior'
import 'modules/popup_panels'
import 'modules/embed_this'
import 'modules/media_viewer'

CssInjection.injectFontIcons();
CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer();
PopupPanels.init();
EmbedThis.init();
MediaViewer.init();
