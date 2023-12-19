import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]
  static values = {
    iiifManifest: String
  }

  resources = {} // Hash of messageIds to content resources
  probes = {} // Hash of messageIds to ProbeServices

  connect() {
    this.fetchIiifManifest()
    window.addEventListener("message", (event) => {
      if (event.origin !== "https://stacks.stanford.edu" && event.origin !== "https://sul-stacks-stage.stanford.edu") return;

      this.checkProbeService(event.data.accessToken, event.data.messageId)
    }, false)

  }

  fetchIiifManifest() {
    fetch(this.iiifManifestValue)
      .then((response) => response.json())
      .then((json) => this.dispatchManifestEvent(json))
      .catch((err) => console.error(err))
  }

  dispatchManifestEvent(json) {
    const event = new CustomEvent('iiif-manifest-received', { detail: json })
    window.dispatchEvent(event)

    this.parseFiles(json)
  }

  parseFiles(document) {
    const canvases = document.items
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
        this.probe(probeService, contentResource.id)
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
  probe(probeService, file_uri) {
    // We're going to make the assumption that calling the probe without a token is going to fail.
    // So we'll just get the token first.
    console.log(probeService)
    const activeAccessService = probeService.service.find((service) => service.type === "AuthAccessService2" && service.profile === "active")

    if (activeAccessService) {
      const tokenService = activeAccessService.service.find((service) => service.type === "AuthAccessTokenService2")
      if (!tokenService)
        throw(`No token service found`)
    //  this.login(activeAccessService)
      const messageId = Math.random().toString(36).slice(2) // random key to reference later
      this.probes[messageId] = probeService
      this.resources[messageId] = file_uri
      const token = this.initiateTokenRequest(tokenService, messageId)
    } else {
      console.log('No active access service found, assume access is granted')
      this.renderViewer(file_uri)
    }
  }

  checkProbeService(token, messageId) {
    const probeService = this.probes[messageId]
    console.log(`Trying probe service for ${messageId} with ${token}`)
    fetch(probeService.id, { headers: { 'Authorization': `Bearer ${token}`}})
      .then((response) => response.json())
      .then((json) => this.probeServiceResult(json, messageId))
      .catch((err) => console.error(err))
  }

  probeServiceResult(json, messageId) {
    console.log("Response from the probe is", json)
    const result = json.status
    if (result == 200) {
      this.renderViewer(this.resources[messageId]) // render viewer if probe service says we are authorized
    }
    // TODO Handle cases where the probe service does not return a 200
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
