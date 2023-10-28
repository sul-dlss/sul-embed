import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

window.Stimulus = Application.start()
const context = require.context("../src/controllers", true, /\.js$/)
Stimulus.load(definitionsFromContext(context))


import { CssInjection } from '../src/modules/css_injection.js';
// import { EmbedThis } from '../src/modules/embed_this.js';
// import { PopupPanels } from '../src/modules/popup_panels.js';
import CommonViewerBehavior from '../src/modules/common_viewer_behavior.js';

import { createRoot } from 'react-dom/client';
import App from '../../assets/javascripts/media_viewer/App'

const domNode = document.querySelector('.media-component');
const root = createRoot(domNode);
root.render(<App />);


$(document).ready(function() {
  CssInjection.injectFontIcons();
  CssInjection.appendToHead();
  CommonViewerBehavior.initializeViewer();
  // PopupPanels.init();
  // EmbedThis.init();
});
