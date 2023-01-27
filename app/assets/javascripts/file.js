/*global CssInjection */

//= require modules/css_injection
//= require vendor/tooltip
//= require modules/common_viewer_behavior
//= require modules/file_preview
//= require modules/popup_panels
//= require modules/embed_this
//= require modules/download_all

CssInjection.injectFontIcons();
CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer();
FilePreview.init();
PopupPanels.init();
EmbedThis.init();
DownloadAll.init();
