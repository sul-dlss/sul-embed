import { initializeViewer } from "../../assets/javascripts/modules/common_viewer_behavior";
import { injectFontIcons, appendToHead } from "../../assets/javascripts/modules/css_injection";
import { initDownloadAll } from "../../assets/javascripts/modules/download_all";
import { initEmbedThis } from "../../assets/javascripts/modules/embed_this";
import FilePreview from "../../assets/javascripts/modules/file_preview";
import PopupPanels from "../../assets/javascripts/modules/popup_panels";

document.addEventListener("DOMContentLoaded", () => {
  injectFontIcons();
  appendToHead();
  initializeViewer();
  FilePreview.init();
  PopupPanels.init();
  initEmbedThis();
  initDownloadAll();
});
