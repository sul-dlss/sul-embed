import M3Viewer from "../src/modules/m3_viewer.js"
import { trackView } from "../src/modules/metrics.js"

document.getElementById("sul-embed-object").hidden = false
M3Viewer.init()

document.addEventListener("DOMContentLoaded", () => {
  trackView()
})
