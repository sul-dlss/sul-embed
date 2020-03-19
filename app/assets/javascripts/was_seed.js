/*global EmbedThis, CssInjection, CommonViewerBehavior, PopupPanels */

//= require common
//= require modules/css_injection
//= require vendor/tooltip
//= require modules/common_viewer_behavior
//= require modules/popup_panels
//= require modules/embed_this
//= require modules/was_seed_viewer
//= require vendor/sly

CssInjection.injectFontIcons();
CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer(WasSeedViewer.init);
PopupPanels.init();
EmbedThis.init();
