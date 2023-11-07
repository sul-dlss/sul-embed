import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

window.Stimulus = Application.start()
const context = require.context("../src/controllers", true, /\.js$/)
Stimulus.load(definitionsFromContext(context))


import { CssInjection } from '../src/modules/css_injection.js';
import { EmbedThis } from '../src/modules/embed_this.js';
import CommonViewerBehavior from '../src/modules/common_viewer_behavior.js';

$(document).ready(function() {
  CssInjection.injectFontIcons();
  CssInjection.appendToHead();
  CommonViewerBehavior.initializeViewer();
  EmbedThis.init();

  const tabs = document.querySelectorAll('[role="tab"]')

  // Add a click event handler to each tab
  tabs.forEach((tab) => {
    tab.addEventListener("click", changeTabs);
  });
});

function changeTabs(e) {
  const target = e.target;
  const parentButton = target.closest('[role="tab"]');
  const tabList = target.closest('[role="tablist"]')

  // Remove all current selected tabs
  tabList
    .querySelectorAll('[aria-selected="true"]')
    .forEach((t) => t.setAttribute("aria-selected", false));

  // Set this tab as selected
  parentButton.setAttribute("aria-selected", true);
}
