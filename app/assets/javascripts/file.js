//= require modules/css_injection
//= require vendor/list.min
//= require modules/file_search
//= require modules/common_viewer_behavior

CssInjection.injectFontAwesome();
CssInjection.appendToHead();
CommonViewerBehavior.showViewer();
FileSearch.init();
