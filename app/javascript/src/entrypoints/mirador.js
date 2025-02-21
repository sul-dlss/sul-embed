console.log('Vite ⚡️ Rails')
console.log('Visit the guide for more information: ', 'https://vite-ruby.netlify.app/guide/rails')

// Example: Load Rails libraries in Vite.
//
// import * as Turbo from '@hotwired/turbo'
// Turbo.start()
//
// import ActiveStorage from '@rails/activestorage'
// ActiveStorage.start()
//
// // Import all channels.
// const channels = import.meta.globEager('./**/*_channel.js')

// Example: Import a stylesheet in app/frontend/index.css
// import '~/index.css'

import M3Viewer from '@/modules/m3_viewer.js';
import { trackView } from '@/modules/metrics.js';

document.getElementById('sul-embed-object').hidden = false;
M3Viewer.init();

document.addEventListener('DOMContentLoaded', () => {
  trackView();
});
