import CommonViewerBehavior from "../../assets/javascripts/modules/common_viewer_behavior";
import CssInjection from "../../assets/javascripts/modules/css_injection";
import EmbedThis from "../../assets/javascripts/modules/embed_this";
import GeoViewer from "../../assets/javascripts/modules/geo_viewer";
import PopupPanels from "../../assets/javascripts/modules/popup_panels";

import "leaflet";
import "../../../vendor/assets/javascripts/Leaflet.Control.Custom";

document.addEventListener("DOMContentLoaded", () => {
  CssInjection.injectFontIcons();
  CssInjection.appendToHead();
  CommonViewerBehavior.initializeViewer(GeoViewer.init);
  PopupPanels.init();
  EmbedThis.init();
});
