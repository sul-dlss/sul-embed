import PopupPanels from "src/modules/popup_panels"
import EmbedThis from "src/modules/embed_this"
import { trackView } from "src/modules/metrics"

document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("sul-embed-object").hidden = false
  PopupPanels.init()
  EmbedThis.init()
  trackView()
})
