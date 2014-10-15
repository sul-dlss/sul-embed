//= require modules/css_injection
//= require vendor/list.min
//= require modules/file_search
//= require modules/common_viewer_behavior
//= require modules/file_preview
//= require modules/metadata_panel

CssInjection.injectFontAwesome();
CssInjection.appendToHead();
CommonViewerBehavior.showViewer();
FileSearch.init();
FilePreview.init();
MetadataPanel.init();
