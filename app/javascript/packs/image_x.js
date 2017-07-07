/*global CssInjection */

import 'openseadragon/build/openseadragon/openseadragon.min'
import 'pubsub-js/src/pubsub'
import 'modules/css_injection'
import 'vendor/tooltip'
import 'vendor/sly'
import 'vendor/manifestor'
import 'vendor/keymaster'
import 'modules/common_viewer_behavior'
import 'modules/popup_panels'
import 'modules/download_panel'
import 'modules/embed_this'
import 'modules/manifest_store'
import 'modules/canvas_store'
import 'modules/image_controls'
import 'modules/iiif_auth'
import 'modules/image_x_viewer'

CssInjection.injectFontIcons();
CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer(ImageXViewer.init);
PopupPanels.init();
EmbedThis.init();
