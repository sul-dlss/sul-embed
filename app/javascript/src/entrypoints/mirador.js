import MiradorViewer from '@/mirador/init.js';
import { trackView } from '@/modules/metrics.js';

document.addEventListener('DOMContentLoaded', () => {
  document.getElementById('sul-embed-object').hidden = false;
  MiradorViewer.init();
  trackView();
});
