import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]
  static values = {
    iiifManifest: String
  }

  resources = {} // Hash of messageIds to content resources
  probes = {} // Hash of messageIds to ProbeServices
  login_already_shown = false

  connect() {
    this.fetchIiifManifest()
    window.addEventListener("message", (event) => {
      if (event.origin !== "https://stacks.stanford.edu" && event.origin !== "https://sul-stacks-stage.stanford.edu") return;

      // this is triggered by the callback from initiateTokenRequest (a call to the IIIF token service on stacks)
      console.log('event received', event)
      this.callProbeService(event.data.accessToken, event.data.messageId)
    }, false)

  }

  fetchIiifManifest() {
    console.log("fetchIiifManifest")
    fetch(this.iiifManifestValue)
      .then((response) => response.json())
      .then((json) => this.parseFiles(json))
      .catch((err) => console.error(err))
  }

  parseFiles(document) {
    console.log("parseFiles")
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

  maybeDrawContentResource(contentResource) {
    console.log("maybeDrawContentResource", contentResource)
    if (!contentResource.service) {
      // no auth service is present, try to render content
      console.log(`No access service found for ${contentResource.id}, assume access is granted`)
      this.renderViewer(contentResource.id)
    } else {
      const probeService = contentResource.service.find((service) => service.type === "AuthProbeService2")
      if (probeService)
        this.setupProbeService(probeService, contentResource.id)
      else
        console.log(`No probe service found for ${contentResource.id}, assume access is granted`)
        // no probe service is present, try to render content
        this.renderViewer(contentResource.id)
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
  setupProbeService(probeService, file_uri) {
    // We're going to make the assumption that calling the probe without a token is going to fail.
    // So we'll just get the token first.
    console.log('setupProbeService', probeService)
    const activeAccessService = probeService.service.find((service) => service.type === "AuthAccessService2" && service.profile === "active")

    if (activeAccessService) {
      const tokenService = activeAccessService.service.find((service) => service.type === "AuthAccessTokenService2")
      if (!tokenService)
        throw(`No token service found`) // TODO: show error message to user?
      const messageId = Math.random().toString(36).slice(2) // random key to reference later
      this.probes[messageId] = probeService
      this.resources[messageId] = file_uri
      const token = this.initiateTokenRequest(tokenService, messageId)
    } else {
      console.log(`No active access service found for ${file_uri}, assume access is granted`)
      this.renderViewer(file_uri)
    }
  }

  callProbeService(token, messageId) {
    console.log('callProbeService')
    const probeService = this.probes[messageId]
    console.log(`Trying probe service for ${messageId} with ${token}`)
    fetch(probeService.id, { headers: { 'Authorization': `Bearer ${token}`}})
      .then((response) => response.json())
      .then((json) => this.probeServiceResult(json, messageId))
      .catch((err) => console.error(err))
  }

  probeServiceResult(probeServiceResponse, messageId) {
    console.log("Response from the probe is", probeServiceResponse)
    const result = probeServiceResponse.status
    if (result == 200) {
      this.renderViewer(this.resources[messageId]) // render viewer if probe service says we are authorized
    } else if (result == 401) {
      // TODO: Show login message: probeServiceResponse.heading.en.0
      this.openLoginWindow(probeServiceResponse.auth_url)
    }
    else {
      console.log(`probeService returned ${result}`)
    }
    // TODO: Handle other cases where the probe service does not return a 200 or a 401?
  }

  initiateTokenRequest(tokenService, messageId) {
    console.log('initiateTokenRequest', tokenService)
    const iframe = document.createElement('iframe')
    iframe.src = `${tokenService.id}?messageId=${messageId}&origin=${window.origin}`
    document.body.appendChild(iframe)
  }

  // Open the login window in a new window and then poll to see if the auth credentials are now active.
  openLoginWindow(url) {
    if (login_already_shown) return // this prevents this window from opening more than once even if multiple files need authorization

    login_already_shown = true
    const windowReference = window.open(url);
    let loginStart = Date.now();
    let checkWindow = setInterval(() => {
      if ((Date.now() - loginStart) < 30000 &&
        (!windowReference || !windowReference.closed)) return;

      clearInterval(checkWindow);
    }, 500)
  }
}
