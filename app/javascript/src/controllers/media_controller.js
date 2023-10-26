import { Controller } from "@hotwired/stimulus"
import videojs from 'video.js';

export default class extends Controller {
  static targets = [ "mediaTag"]

  connect() {
    // TODO: Auth check
    this.mediaTagTarget.classList.add('video-js', 'vjs-default-skin');
    videojs(this.mediaTagTarget.id).removeChild('textTrackSettings')
    // const vjs = videojs(mediaObject.id);
    // vjs.removeChild('textTrackSettings')
    // console.log("DOOOD")
    // this.element.textContent = "Hello World!"
  }
}