import "controllers";
import { trackView, trackFileDownloads } from "src/modules/metrics";

document.addEventListener("DOMContentLoaded", () => {
  trackView();
  trackFileDownloads();
});
