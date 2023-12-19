import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  resources = {} // Hash of messageIds to resources

  addPostCallbackListener() {
    window.addEventListener("message", (event) => {
      if (event.origin !== "https://stacks.stanford.edu" && event.origin !== "https://sul-stacks-stage.stanford.edu") return;
      if (event.data.type === "AuthAccessTokenError2") {
        this.displayAccessTokenError(event.data)
      } else {
        this.accessTokenReceived(event.data.accessToken, event.data.messageId)
      }
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
        this.probe(probeService, contentResource.id)
      else
        throw(`No probe service found for ${contentResource.id}`)
    }
  }

  renderViewer(file_uri) {
    window.dispatchEvent(new CustomEvent('auth-success', { detail: file_uri }))
  }

  // https://iiif.io/api/auth/2.0/#71-authorization-flow-algorithm
  probe(probeService, contentResourceId) {
    // We're going to make the assumption that calling the probe without a token is going to fail.
    // So we'll just get the token first.
    console.log(probeService)
    const accessService = probeService.service.find((service) => service.type === "AuthAccessService2")

    if (!accessService)
      throw(`No access service found`)

    const tokenService = accessService.service.find((service) => service.type === "AuthAccessTokenService2")
    if (!tokenService)
      throw(`No token service found`)

    if (accessService.profile === "active")
      this.login(accessService)

    const messageId = 'ae3415' // TODO: Make this random
    this.resources[messageId] = { probeService, contentResourceId }
    this.initiateTokenRequest(tokenService, messageId)
  }

  displayAccessTokenError(accessTokenError) {
    console.error("There was an error getting the token", accessTokenError)
    alert("Authentication error. Unable to get a token from Stacks.")
  }

  accessTokenReceived(token, messageId) {
    const resource = this.resources[messageId]
    console.log("Trying probe service")
    fetch(resource.probeService.id, { headers: { 'Authorization': `Bearer ${token}`}})
      .then((response) => response.json())
      .then((json) => this.handleProbeResponse(json, resource.contentResourceId))
      .catch((err) => console.error(err))
  }

  handleProbeResponse(probeResponse, contentResourceId) {
    if (probeResponse.status === 200) {
      this.renderViewer(contentResourceId)
    } else {
      throw(`Unable to handle probeResponse`, probeResponse)
    }
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
