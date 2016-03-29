/*global CssInjection */

//= require modules/css_injection
//= require modules/common_viewer_behavior
//= require modules/popup_panels
//= require modules/embed_this

CssInjection.injectFontIcons();
CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer();
PopupPanels.init();
EmbedThis.init();
