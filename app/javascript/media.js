import "@videojs/html/video"
import "@videojs/html/media/hlsjs-video"
import "controllers"
import { trackView } from "src/modules/metrics"

document.addEventListener("DOMContentLoaded", () => {
  trackView()
})
