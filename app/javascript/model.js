import "controllers"

import ModelViewer from "src/modules/model_viewer"
import { trackView } from "src/modules/metrics"

import "@google/model-viewer"

document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("sul-embed-object").hidden = false
  ModelViewer.init()
  trackView()
})
