"use strict";

import "controllers";

import EmbedThis from "src/modules/embed_this";
import PopupPanels from "src/modules/popup_panels";
import ModelViewer from "src/modules/model_viewer";
import { trackView } from "src/modules/metrics";

import "@google/model-viewer";

document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("sul-embed-object").hidden = false;
  ModelViewer.init();
  PopupPanels.init();
  EmbedThis.init();
  trackView();
});
