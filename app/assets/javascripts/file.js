/*global CssInjection */

//= require modules/css_injection
//= require list.js/dist/list
//= require vendor/tooltip
//= require modules/file_search
//= require modules/common_viewer_behavior
//= require modules/file_preview
//= require modules/popup_panels
//= require modules/embed_this

CssInjection.injectFontIcons();
CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer();
FileSearch.init();
FilePreview.init();
PopupPanels.init();
EmbedThis.init();
