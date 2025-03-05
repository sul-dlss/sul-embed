import "controllers"

import { trackView } from "src/modules/metrics"

import "@google/model-viewer"

document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("sul-embed-object").hidden = false
  trackView()
})
