import CommonViewerBehavior from "../../assets/javascripts/modules/common_viewer_behavior.js";
import CssInjection from "../../assets/javascripts/modules/css_injection.js";
import EmbedThis from "../../assets/javascripts/modules/embed_this.js";
import MediaViewer from "../../assets/javascripts/modules/media_viewer.js";
import PopupPanels from "../../assets/javascripts/modules/popup_panels.js";

document.addEventListener("DOMContentLoaded", () => {
  CssInjection.injectFontIcons();
  CssInjection.appendToHead();
  CommonViewerBehavior.initializeViewer();
  PopupPanels.init();
  EmbedThis.init();
  MediaViewer.init();
});
