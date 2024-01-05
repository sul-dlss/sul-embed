import EmbedThis from 'src/modules/embed_this';
import PopupPanels from 'src/modules/popup_panels';
import { trackView } from 'src/modules/metrics';
import "file_controllers"

document.addEventListener('DOMContentLoaded', () => {
  document.getElementById('sul-embed-object').hidden = false
  PopupPanels.init();
  EmbedThis.init();
  trackView();
})
