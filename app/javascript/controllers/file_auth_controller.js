import { Controller } from "@hotwired/stimulus"
// import validator from 'src/modules/validator'
// import mediaTagTokenWriter from 'src/modules/media_tag_token_writer'
// import buildThumbnail from 'src/modules/media_thumbnail_builder'

export default class extends Controller {
  static targets = ["container"]

  resources = {} // Hash of messageIds to resources

  addPostCallbackListener() {
    window.addEventListener("message", (event) => {
      if (event.origin !== "https://stacks.stanford.edu" && event.origin !== "https://sul-stacks-stage.stanford.edu") return;

      this.accessTokenReceived(event.data.accessToken, event.data.messageId)
    }, false)
  }

  parseFiles(evt) {
    const document = evt.detail
    const canvases = document.items
    this.addPostCallbackListener()
    canvases.forEach((canvas) => {
      const annotationPages = canvas.items
      annotationPages.forEach((annotationPage) => {
        const annotations = annotationPage.items
        annotations.forEach((annotation) => {
          if (annotation.motivation === "painting") {
            const contentResource = annotation.body
            this.maybeDrawContentResource(contentResource)
          }
        })
      })
    })
  }

  // TODO: This causes 1 login window to open for each resource that needs a login.
  //       Instead we should open one window if any resource needs a login.
  maybeDrawContentResource(contentResource) {
    console.log("Now figure out if we can render", contentResource)
    if (!contentResource.service) {
      // no auth is present, render it
      this.renderViewer(contentResource.id)
    } else {
      const probeService = contentResource.service.find((service) => service.type === "AuthProbeService2")
      if (probeService)
        this.probe(probeService)
      else
        throw(`No probe service found for ${contentResource.id}`)
    }
  }

  renderViewer(file_uri) {
    this.containerTarget.innerHTML = `
      <object data="${file_uri}" type="application/pdf" style="height: 100vh; width: 100%">
        <p>Your browser does not support viewing PDFs.  Please <a href="${file_uri}">download the file</a> to view it.</p>
      </object>
    `
  }

  // https://iiif.io/api/auth/2.0/#71-authorization-flow-algorithm
  probe(probeService) {
    // We're going to make the assumption that calling the probe without a token is going to fail.
    // So we'll just get the token first.
    console.log(probeService)
    const activeAccessService = probeService.service.find((service) => service.type === "AuthAccessService2" && service.profile === "active")

    if (activeAccessService) {
      const tokenService = activeAccessService.service.find((service) => service.type === "AuthAccessTokenService2")
      if (!tokenService)
        throw(`No token service found`)
      this.login(activeAccessService)
      const messageId = 'ae3415' // TODO: Make this random
      this.resources[messageId] = probeService
      const token = this.initiateTokenRequest(tokenService, messageId)
    } else {
      throw(`No active access service found`)
    }
  }

  accessTokenReceived(token, messageId) {
    const probeService = this.resources[messageId]
    console.log("Trying probe service")
    fetch(probeService.id, { headers: { 'Authorization': `Bearer ${token}`}})
      .then((response) => response.json())
      .then((json) => console.log("Response from the probe is", json))
      .catch((err) => console.error(err))
  }

  initiateTokenRequest(tokenService, messageId) {
    const iframe = document.createElement('iframe')
    iframe.src = `${tokenService.id}?messageId=${messageId}&origin=${window.origin}`
    document.body.appendChild(iframe)
  }

  // Open the login window in a new window and then poll to see if the auth credentials are now active.
  login(activeAccessService) {
    const windowReference = window.open(activeAccessService.id);
    let loginStart = Date.now();
    let checkWindow = setInterval(() => {
      if ((Date.now() - loginStart) < 30000 &&
        (!windowReference || !windowReference.closed)) return;

      clearInterval(checkWindow);
    }, 500)
  }
}
