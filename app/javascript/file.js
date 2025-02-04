import "controllers"
import "file_controllers"
import { trackView } from "src/modules/metrics"

document.addEventListener("DOMContentLoaded", () => {
  trackView()
})
