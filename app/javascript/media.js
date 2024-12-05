import "controllers"
import { trackView } from "src/modules/metrics"

document.addEventListener("DOMContentLoaded", () => {
  trackView()
})
