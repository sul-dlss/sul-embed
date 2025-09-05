import MiradorViewer from "../src/modules/mirador_viewer.js"
import { trackView } from "../src/modules/metrics.js"

document.getElementById("sul-embed-object").hidden = false
MiradorViewer.init()

document.addEventListener("DOMContentLoaded", () => {
  trackView()
})
