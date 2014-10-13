//= require vendor/openseadragon.min
//= require modules/css_injection
//= require modules/jquery.embedOsdViewer

CssInjection.injectFontAwesome();
CssInjection.appendToHead();

$('.sul-embed-osd').embedOsdViewer();
