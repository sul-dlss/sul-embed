import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "mediaWrapper" ]

  connect() {
    this.findThumbnails()
  }

  // Currently this finds certain data-* properties on the media wrapper which we can make thumbnails with.
  // Once these properties are found we emit a thumbnails-found event.  The content_list_controller.js
  // can then receive this event and draw the content of the thubmnail list.
  // TODO: in the future, we should drive the thumbnail list from the data in the IIIF manifest.
  findThumbnails() {
    const thumbnails = this.mediaWrapperTargets.
      map((mediaDiv) => {
        const dataset = mediaDiv.dataset
        return { fileUri: dataset.fileUri,
                 isStanfordOnly: dataset.stanfordOnly === "true",
                 thumbnailUrl: dataset.thumbnailUrl,
                 defaultIcon: dataset.defaultIcon,
                 isLocationRestricted: dataset.locationRestricted === "true",
                 fileLabel: dataset.fileLabel || '' }
      })

    // Timeout is set because when the page is cached, the event fires before the content_list_controller is mounted.
    // This causes the sidebar not to load: https://github.com/sul-dlss/sul-embed/issues/2175
    setTimeout(() => {
      window.dispatchEvent(new CustomEvent('thumbnails-found', { detail: thumbnails }))
    }, "100");
  }
}
