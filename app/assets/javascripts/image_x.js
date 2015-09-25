/*global CssInjection */

//= require openseadragon/built-openseadragon/openseadragon/openseadragon.min
//= require pubsub-js/src/pubsub
//= require modules/css_injection
//= require vendor/tooltip
//= require vendor/sly
//= require vendor/manifestor
//= require vendor/keymaster
//= require modules/common_viewer_behavior
//= require modules/popup_panels
//= require modules/download_panel
//= require modules/embed_this
//= require modules/manifest_store
//= require modules/layout_store
//= require modules/canvas_store
//= require modules/image_x_viewer

CssInjection.injectFontIcons();
CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer(ImageXViewer.init);
PopupPanels.init();
EmbedThis.init();
