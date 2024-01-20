import "controllers";
import { trackView } from "src/modules/metrics";
import Fullscreen from "src/modules/fullscreen";

document.addEventListener("DOMContentLoaded", () => {
  Fullscreen.init(".sul-embed-pdf");
  trackView();
});
