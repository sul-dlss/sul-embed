/*global CssInjection */

//= require modules/css_injection
//= require vendor/tooltip
//= require modules/common_viewer_behavior
//= require modules/popup_panels
//= require modules/embed_this
//= require leaflet
//= require Leaflet.Control.Custom.js
//= require modules/geo_viewer
//= require handlebars.runtime
//= require templates/index_map_info
//= require templates/geo_sidebar

CssInjection.injectFontIcons();
CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer(GeoViewer.init);
PopupPanels.init();
EmbedThis.init();
