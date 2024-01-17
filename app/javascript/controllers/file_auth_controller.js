import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "loginPanel", "messagePanel", "loginButton", "loginMessage"]

  resources = {} // Hash of messageIds to resources

  addPostCallbackListener() {
    window.addEventListener("message", (event) => {
      this.iframe.remove()
      console.log("Post message", event.data)
      if (event.origin !== "https://stacks.stanford.edu" && event.origin !== "https://sul-stacks-stage.stanford.edu") return;
      if (event.data.type === "AuthAccessTokenError2") {
        this.displayAccessTokenError(event.data)
      } else {
        this.cacheToken(event.data.accessToken, event.data.expiresIn)
        this.queryProbeService(event.data.messageId, event.data.accessToken)
          .then((contentResourceId) => this.renderViewer(contentResourceId))
          .catch((json) => console.error("no access", json))
      }
    }, false)
  }

  // iterate over all files in the IIIF manifest and try to draw them
  // this method is called by stimulus reflex in the content type component after the IIIF manifest is loaded
  parseFiles(evt) {
    const document = evt.detail
    const canvases = document.items
    this.addPostCallbackListener()
    canvases.flatMap((canvas) => {
      const annotationPages = canvas.items
      return annotationPages.flatMap((annotationPage) => {
        const paintingAnnotations = annotationPage.items.filter((annotation) => annotation.motivation === "painting")
        return paintingAnnotations.map((annotation) => {
          const contentResource = annotation.body
          this.maybeDrawContentResource(contentResource)
          return contentResource
        })
      })
    })
    // TODO: Deal with thumbnail views
    // const thumbnails = paintingResources.map((resource) => {
    //   return { isStanfordOnly: false,
    //            thumbnailUrl: '',
    //            defaultIcon: '',
    //            isLocationRestricted: false,
    //            fileLabel: resource.label }
    // })
    // window.dispatchEvent(new CustomEvent('thumbnails-found', { detail: thumbnails }))
  }

  // Try to render the resource, checks for any required authorization and shows login window if needed
  maybeDrawContentResource(contentResource) {
    console.log("Now figure out if we can render", contentResource)
    if (!contentResource.service) {
      // no auth service is present, just render the resource
      this.renderViewer(contentResource.id)
    } else {
      // auth service is present, check the probe service to see what we need to do to access the resource
      const probeService = contentResource.service.find((service) => service.type === "AuthProbeService2")
      if (probeService)
        this.checkAuthorization(probeService, contentResource.id)
      else
        throw(`Access service exists, but no probe service found for ${contentResource.id}`)
    }
  }

  // Render the resource by sending an event to stimulus reflex; the relevant content type component must catch this
  // event, and call a method for that partcular content type (e.g. pdf/media) that knows how to render content
  renderViewer(file_uri) {
    window.dispatchEvent(new CustomEvent('auth-success', { detail: file_uri }))
  }

  /**
   * Puts the token in the cache
   * @param {string} accessToken - The token itself
   * @param {number} expiresIn - The number of seconds until the token ceases to be valid.
   */
  cacheToken(accessToken, expiresIn) {
    console.log("Storing token in cache")
    // Get a Date that is expiresIn seconds in the future.
    const expires = new Date(new Date().getTime() + expiresIn * 1000)
    localStorage.setItem('accessToken', JSON.stringify({ accessToken, expires }))
  }

  // Try to find a cached token in local storage
  getCachedToken() {
    const json = localStorage.getItem('accessToken')
    console.log("Cached token is ", json)
    if (!json)
      return
    try {
      const { accessToken, expires } = JSON.parse(json)
      if (new Date() < new Date(expires))
        return accessToken
      else
        console.log("Cached token expired", expires)
    } catch {
      // Clear out any broken storage
      localStorage.clear()
    }
  }

  // If an access service is provided for the given resource, check the provided probe service to see
  // what the user needs to do to access the resource.  We will cache any token provided so the user
  // does not need to do this again for future resources in the same session.
  // https://iiif.io/api/auth/2.0/#71-authorization-flow-algorithm
  checkAuthorization(probeService, contentResourceId) {
    // We're going to make the assumption that calling the probe without a token is going to fail.
    // So we'll just get the token first.
    console.log(probeService)
    const accessService = this.findAccessService(probeService)

    const messageId = Math.random().toString(36).slice(2) // create a random key for this resource to reference later
    this.resources[messageId] = { probeService, contentResourceId }

    // First we check the probe service for the resource.  If probe service indicates no restrictions,
    // then the resource is shown.  If the probe service indicates access is denied/restricted, we
    // check the local storage for any existing cached token, and try the probe service again with the token.
    // If probe service denies access with the cached token OR there is no cached token, check the access service
    // to get the login message and URL needed to show to the user.
    this.queryProbeService(messageId)
      .then((contentResourceId) => this.renderViewer(contentResourceId))
      .catch((json) => {
        console.log("Probe failed or access denied/restricted", json)
        // Check if non-expired token already exists in local storage,
        // and if it exists, query probe service with it
        const token = this.getCachedToken()
        if (token) {
          this.queryProbeService(messageId, token)
            .then((contentResourceId) => this.renderViewer(contentResourceId))
            .catch((json) => {
              console.log("Probe with cached token failed", json)
              this.queryAccessService(accessService, messageId)
            })
        } else {
          console.log("No cached token found")
          this.queryAccessService(accessService, messageId)
        }
      })
  }

  // query the accessService to see if a login is needed first; else just request a token
  queryAccessService(accessService, messageId) {
    if (accessService.profile === "active") {
      this.loginNeeded(accessService, messageId)
    } else {
      this.initiateTokenRequest(accessService, messageId)
    }
  }

  // locate the access service for this resource
  findAccessService(probeService) {
    const accessService = probeService.service.find((service) => service.type === "AuthAccessService2")

    if (!accessService)
      throw(`No access service found`)

    return accessService
  }

  // locate the token service for this access service
  findTokenService(accessService) {
    const tokenService = accessService.service.find((service) => service.type === "AuthAccessTokenService2")
    if (!tokenService)
      throw(`No token service found`)

    return tokenService
  }

  // An error occurred obtaining a token
  displayAccessTokenError(accessTokenError) {
    console.error("There was an error getting the token", accessTokenError)
    alert("An authentication error occurred. You may not be able to view content at this time.")
    const resource = this.resources[accessTokenError.messageId]
    const activeAccessService = this.findAccessService(resource.probeService)
    this.loginNeeded(activeAccessService, accessTokenError.messageId)
  }

  // Query the probe service (and add a token if available)
  // NOTE: Token is optional
  queryProbeService(messageId, token) {
    const resource = this.resources[messageId]
    console.log("Trying probe service with ", token)
    const headers = {}
    if (token) {
      headers['Authorization'] = `Bearer ${token}`
    }
    const contentResourceId = resource.contentResourceId
    return fetch(resource.probeService.id, { headers })
      .then((response) => response.json())
      .then((json) => new Promise((resolve, reject) => json.status === 200 ? resolve(contentResourceId) : reject(json)))
  }

  // Fetch a token for the provided resource
  initiateTokenRequest(accessService, messageId) {
    const tokenService = this.findTokenService(accessService)

    this.iframe = document.createElement('iframe')
    this.iframe.src = `${tokenService.id}?messageId=${messageId}&origin=${window.origin}`
    console.log(`Creating iframe for ${tokenService.id}`)
    document.body.appendChild(this.iframe)
  }

  // Show login message and link provided by auth service
  loginNeeded(activeAccessService, messageId) {
    if (!this.loginPanelTarget.hidden) return // no action needed if the login window is already there

    this.messagePanelTarget.hidden = true
    this.loginPanelTarget.hidden = false
    this.loginButtonTarget.innerHTML = activeAccessService.confirmLabel.en[0]
    this.loginButtonTarget.setAttribute('data-file-auth-messageId-param', messageId)
    this.loginButtonTarget.setAttribute('data-file-auth-url-param', activeAccessService.id)
    this.loginMessageTarget.innerHTML = activeAccessService.label.en[0]
  }

  // Open the login page in a new window and then poll to see if the auth credentials are now active.
  // This method is triggered by stimulus reflex when the user clicks the login button rendered by `loginNeeded`
  login(evt) {
    this.loginPanelTarget.hidden = true
    const windowReference = window.open(evt.params.url);
    let loginStart = Date.now();
    console.log("window reference", windowReference)
    let checkWindow = setInterval(() => {
      console.log("in interval", (Date.now() - loginStart))
      if ((Date.now() - loginStart) < 30000 &&
        (!windowReference || !windowReference.closed)) return;

      clearInterval(checkWindow);
      // once the window is closed we can initiate the token request
      this.afterLoginWindowClosed(evt.params.messageid)
    }, 500)
  }

  // Once the login window is closed, we can try and get a token for the resource
  afterLoginWindowClosed(messageId) {
    console.log("Done waiting on the login window")
    const probeService = this.resources[messageId].probeService
    const accessService = this.findAccessService(probeService)
    this.messagePanelTarget.hidden = false

    this.initiateTokenRequest(accessService, messageId)
  }

  hideMessagePanel() {
    this.messagePanelTarget.hidden = true
  }
}
