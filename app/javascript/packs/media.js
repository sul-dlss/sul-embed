import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

window.Stimulus = Application.start()
const context = require.context("../src/controllers", true, /\.js$/)
Stimulus.load(definitionsFromContext(context))

import { EmbedThis } from '../src/modules/embed_this.js';
import CommonViewerBehavior from '../src/modules/common_viewer_behavior.js';

$(document).ready(function() {
  CommonViewerBehavior.initializeViewer();
  EmbedThis.init();
});