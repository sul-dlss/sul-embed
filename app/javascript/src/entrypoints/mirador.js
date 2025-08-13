import M3Viewer from '@/mirador/init.js';
import { trackView } from '@/modules/metrics.js';

document.addEventListener('DOMContentLoaded', () => {
  document.getElementById('sul-embed-object').hidden = false;
  M3Viewer.init();
  trackView();
});
