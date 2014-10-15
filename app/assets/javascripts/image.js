//= require vendor/openseadragon.min
//= require modules/css_injection
//= require modules/jquery.embedOsdViewer
//= require modules/common_viewer_behavior

CssInjection.injectFontAwesome();
CssInjection.appendToHead();
CommonViewerBehavior.showViewer();
$('.sul-embed-osd').embedOsdViewer();
