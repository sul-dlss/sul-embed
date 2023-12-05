import EmbedThis from '../src/modules/embed_this';
import PopupPanels from '../src/modules/popup_panels';
import { DownloadAll } from '../src/modules/download_all';
import '../src/tree'

document.addEventListener('DOMContentLoaded', () => {
  document.getElementById('sul-embed-object').hidden = false
  PopupPanels.init();
  EmbedThis.init();
  DownloadAll.init();
})