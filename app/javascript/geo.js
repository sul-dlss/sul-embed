import "controllers"
import { trackView } from "src/modules/metrics"
import GeoViewer from "src/modules/geo_viewer"
import "leaflet"
import "Leaflet.Control.Custom"

document.addEventListener("DOMContentLoaded", () => {
  GeoViewer.init()
  trackView()
})
