import { Controller } from "@hotwired/stimulus"
import GeoViewer from "src/modules/geo_viewer"

export default class extends Controller {

  show(evt) {
    GeoViewer.updateVisualizationLayer(evt.detail.location);
  }
}