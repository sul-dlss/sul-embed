// Require React libraries and components (this ordering is specific)
//= require vendor/es5-shim
//= require vendor/es5-sham
//= require react
//= require components
//= require react_ujs

//= require modules/css_injection
//= require listjs/dist/list
//= require vendor/tooltip
//= require modules/file_search
//= require modules/common_viewer_behavior
//= require modules/file_preview
//= require modules/popup_panels
//= require modules/embed_this

CssInjection.injectFontAwesome();
CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer();
FileSearch.init();
FilePreview.init();
PopupPanels.init();
EmbedThis.init();
