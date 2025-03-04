import EmbedThis from "src/modules/embed_this"
import PopupPanels from "src/modules/popup_panels"
import GeoViewer from "src/modules/geo_viewer"
import { trackView } from "src/modules/metrics"

import "leaflet"
import "Leaflet.Control.Custom"

document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("sul-embed-object").hidden = false
  GeoViewer.init()
  PopupPanels.init()
  EmbedThis.init()
  trackView()
})
