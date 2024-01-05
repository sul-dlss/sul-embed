"use strict";

import EmbedThis from "src/modules/embed_this";
import PopupPanels from "src/modules/popup_panels";
import Fullscreen from "src/modules/fullscreen";
import { trackView } from "src/modules/metrics";

document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("sul-embed-object").hidden = false;
  PopupPanels.init();
  EmbedThis.init();
  Fullscreen.init(".sul-embed-pdf");
  trackView();
});
