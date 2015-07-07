//= require modules/css_injection
//= require vendor/tooltip
//= require modules/common_viewer_behavior
//= require modules/popup_panels
//= require modules/embed_this
//= require leaflet

CssInjection.injectFontAwesome();
CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer();
PopupPanels.init();
EmbedThis.init();

var map = L.map('sul-embed-geo-map').setView([51.505, -0.09], 13);

L.tileLayer(
    'https://otile{s}-s.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, Tiles Courtesy of <a href="http://www.mapquest.com/" target="_blank">MapQuest</a> <img src="//developer.mapquest.com/content/osm/mq_logo.png" alt="">',
      maxZoom: 18,
      worldCopyJump: true,
      subdomains: '1234' // see http://developer.mapquest.com/web/products/open/map
    }
).addTo(map);
