import EmbedThis from 'src/modules/embed_this';
import PopupPanels from 'src/modules/popup_panels';
import { trackView, trackFileDownloads, trackObjectDownload } from 'src/modules/metrics';
import "file_controllers"

document.addEventListener('DOMContentLoaded', () => {
  document.getElementById('sul-embed-object').hidden = false
  PopupPanels.init();
  EmbedThis.init();
  trackView();
  trackFileDownloads();

  document.querySelector('button[aria-label="download all files"]').addEventListener('click', () => {
    trackObjectDownload();
  });
})
