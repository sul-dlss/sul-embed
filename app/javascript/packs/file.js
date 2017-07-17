/*global CssInjection */

import 'modules/css_injection'
import 'list.js'
import 'vendor/tooltip'
import 'modules/file_search'
import 'modules/common_viewer_behavior'
import 'modules/file_preview'
import 'modules/popup_panels'
import 'modules/embed_this'

CssInjection.injectFontIcons();
CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer();
FileSearch.init();
FilePreview.init();
PopupPanels.init();
EmbedThis.init();
