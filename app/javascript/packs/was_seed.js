/*global EmbedThis, CssInjection, CommonViewerBehavior, PopupPanels */

import 'modules/css_injection'
import 'vendor/tooltip'
import 'modules/common_viewer_behavior'
import 'modules/popup_panels'
import 'modules/embed_this'
import 'modules/was_seed_viewer'
import 'vendor/sly'

CssInjection.injectFontIcons();
CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer(WasSeedViewer.init);
PopupPanels.init();
EmbedThis.init();
