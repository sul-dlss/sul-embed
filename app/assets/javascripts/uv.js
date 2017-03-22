/*global CssInjection */

//= require modules/css_injection
//= require modules/common_viewer_behavior
//= require modules/popup_panels
//= require modules/embed_this
//= require uv-2.0.1/lib/embed.js

CssInjection.injectFontIcons();
CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer();
PopupPanels.init();
EmbedThis.init();