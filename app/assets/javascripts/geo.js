//= require modules/css_injection
//= require vendor/tooltip
//= require modules/common_viewer_behavior
//= require modules/popup_panels
//= require modules/embed_this

CssInjection.injectFontAwesome();
CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer();
PopupPanels.init();
EmbedThis.init();
