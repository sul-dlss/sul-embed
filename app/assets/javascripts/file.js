/*global CssInjection */

//= require modules/css_injection
//= require vendor/tooltip
//= require modules/common_viewer_behavior
//= require modules/file_preview
//= require modules/dir_toggle
//= require modules/popup_panels
//= require modules/embed_this

CssInjection.injectFontIcons();
CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer();
FilePreview.init();
PopupPanels.init();
EmbedThis.init();
