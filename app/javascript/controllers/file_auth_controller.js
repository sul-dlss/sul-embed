import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  resources = {} // Hash of messageIds to resources

  addPostCallbackListener() {
    const permittedOrigins = ["https://stacks.stanford.edu", "https://sul-stacks-stage.stanford.edu", "https://stacks-uat.stanford.edu"]
    window.addEventListener("message", (event) => {
      console.debug("Post message", event.data)
      if (!permittedOrigins.includes(event.origin)) {
        console.error(`${event.origin} is not a permitted origin`)
        return
      }
      this.iframe.remove()
      if (event.data.type === "AuthAccessTokenError2") {
        this.displayAccessTokenError(event.data)
      } else {
        this.cacheToken(event.data.accessToken, event.data.expiresIn)
        window.dispatchEvent(new CustomEvent('show-message-panel', { detail: {} }))
        this.queryProbeService(event.data.messageId, event.data.accessToken)
          .then((result) => this.renderViewer(result))
          .catch((json) => console.error("no access", json))
      }
    }, false)
  }

  // iterate over all files in the IIIF manifest and try to draw them
  // this method is called by stimulus in the content type component after the IIIF manifest is loaded
  parseFiles(evt) {
    const manifest = evt.detail
    const canvases = manifest.items
    this.addPostCallbackListener()
    this.documents = canvases.flatMap((canvas) => {
      const annotationPages = canvas.items
      return annotationPages.flatMap((annotationPage) => {
        const paintingAnnotations = annotationPage.items.filter((annotation) => annotation.motivation === "painting")
        return paintingAnnotations.map((annotation) => {
          const contentResource = annotation.body
          return contentResource
        })
      })
    })
    this.maybeDrawContentResource(this.documents[0]) // cause login to first resource
  }

  // Triggered when clicking on a thumbnail
  // Leads to authorization check of the file and displays the correct access banner or renders viewer
  authFileAndDisplay(event) {
    const document = this.documents.find((document) => document.id == event.detail.fileUri)
    if (document)
      this.maybeDrawContentResource(document)
    else
      throw("No document found for", event.detail.fileUri)
  }

  // Try to render the resource, checks for any required authorization and shows login window if needed
  maybeDrawContentResource(contentResource) {
    console.debug("Now figure out if we can render", contentResource)
    if (!contentResource.service) {
      // no service is present, just render the resource
      this.renderViewer({ fileUri: contentResource.id })
    } else {
      // see if there is a probe service to see what we need to do to access the resource
      const probeService = contentResource.service.find((service) => service.type === "AuthProbeService2")
      if (probeService)
        this.checkAuthorization(probeService, contentResource.id)
      else {
        console.debug(`Access service exists, but no probe service found for ${contentResource.id}`)
        const imageService = contentResource.service.find((service) => service.type === "ImageService2")
         // handle legacy ImageService2 (no imageService.service implies world access)
        if (imageService && imageService.service) {
          // authv1
        } else {
          console.warn(`No imageservice found for ${contentResource.id}`)
        }
      }
    }
  }

  // This is called after we have done authorization and we want to display the first resource to the user.
  // Render the resource by sending an event to stimulus; the relevant content type component must catch this
  // event, and call a method for that partcular content type (e.g. pdf/media) that knows how to render content
  renderViewer(result) {
    const fileUri = result.fileUri
    console.log("Auth-success event", fileUri)
    window.dispatchEvent(new CustomEvent('auth-success', { detail: { fileUri: fileUri, location: result.location } }))
    // use filename because url in contents adds druid: to the data-url
    const filename = fileUri.split("/").slice(-1)[0]
    const contentItem = document.querySelector(`[data-url*="${filename}"]`)
    if (contentItem) {
      contentItem.parentElement.classList.add('active')
    }
  }

  /**
   * Puts the token in the cache
   * @param {string} accessToken - The token itself
   * @param {number} expiresIn - The number of seconds until the token ceases to be valid.
   */
  cacheToken(accessToken, expiresIn) {
    console.debug("Storing token in cache")
    // Get a Date that is expiresIn seconds in the future.
    const expires = new Date(new Date().getTime() + expiresIn * 1000)
    localStorage.setItem('accessToken', JSON.stringify({ accessToken, expires }))
  }

  // Try to find a cached token in local storage
  getCachedToken() {
    const json = localStorage.getItem('accessToken')
    console.debug("Cached token is ", json)
    if (!json)
      return
    try {
      const { accessToken, expires } = JSON.parse(json)
      if (new Date() < new Date(expires))
        return accessToken
      else
        console.debug("Cached token expired", expires)
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
    console.debug("Found probe service:", probeService)
    const accessService = this.findAccessService(probeService)

    const messageId = Math.random().toString(36).slice(2) // create a random key for this resource to reference later
    this.resources[messageId] = { probeService, contentResourceId }

    // First we check the probe service for the resource.  If probe service indicates no restrictions,
    // then the resource is shown.  If the probe service indicates access is denied/restricted, we
    // check the local storage for any existing cached token, and try the probe service again with the token.
    // If probe service denies access with the cached token OR there is no cached token, check the access service
    // to get the login message and URL needed to show to the user.
    // https://stacks.stanford.edu/iiif/auth/v2/probe?id=FULL_PATH_TO_FILE
    this.queryProbeService(messageId)
      .then((result) => this.renderViewer(result))
      .catch((authResponse) => {

        // Intercept the response and check for files that can't be accessed before trying to log in, because
        // logging in won't help the fact that we're not in an authorized location/file is no download/embargoed (without stanford login).
        if (authResponse.status == '403') return this.authDenied(authResponse)

        // Check if non-expired token already exists in local storage,
        // and if it exists, query probe service with it
        const token = this.getCachedToken()
        if (token) {
          this.queryProbeService(messageId, token)
            .then((result) => {
              this.showLoggedInBanner(authResponse)
              this.renderViewer(result)
            })
            .catch((json) => {
              console.debug("Probe with cached token failed", json)
              this.queryAccessService(accessService, messageId)
            })
        } else {
          console.debug("No cached token found")
          this.queryAccessService(accessService, messageId)
        }
      })
  }

  // check to see if the item is stanford restricted
  // if it is and the user is already logged in, show the logged in banner
  // We need to do this check because the response with token will return a 200 and no other information.
  showLoggedInBanner(prevAuthResponse) {
    if (prevAuthResponse.status == 401 && prevAuthResponse.heading.en[0].includes('log in')){
      window.dispatchEvent(new CustomEvent('show-message-panel', { detail: {} }))
    }
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
    console.debug("Trying probe service with token: ", token)
    const headers = {}
    if (token) {
      headers['Authorization'] = `Bearer ${token}`
    }
    console.debug("Fetching probe service", resource.probeService.id)
    return fetch(resource.probeService.id, { headers })
      .then((response) => response.json())
      .then((json) => new Promise((resolve, reject) => {
        return (json.status === 200 || json.status === 302) ? resolve({ fileUri: resource.contentResourceId, location: json.location?.id }) : reject(json)
      } ) )
  }

  // Fetch a token for the provided resource
  initiateTokenRequest(accessService, messageId) {
    const tokenService = this.findTokenService(accessService)

    this.iframe = document.createElement('iframe')
    this.iframe.src = `${tokenService.id}?messageId=${messageId}&origin=${window.origin}`
    console.debug(`Creating iframe for ${tokenService.id}`)
    document.body.appendChild(this.iframe)
  }

  // Show login message and link provided by auth service
  loginNeeded(activeAccessService, messageId) {
    // This allows the lock window to show
    const event = new CustomEvent('needs-login', { detail: { activeAccessService: activeAccessService, messageId: messageId } })
    window.dispatchEvent(event)
  }

  // Open the login page in a new window and then poll to see if the auth credentials are now active.
  // This method is triggered by stimulus when the user clicks the login button rendered by `loginNeeded`
  login(evt) {
    const windowReference = window.open(evt.params.url)
    let loginStart = Date.now()
    console.debug("window reference", windowReference)
    let checkWindow = setInterval(() => {
      console.debug("in interval", (Date.now() - loginStart))
      if ((Date.now() - loginStart) < 30000 &&
        (!windowReference || !windowReference.closed)) return

      clearInterval(checkWindow)
      // once the window is closed we can initiate the token request
      this.afterLoginWindowClosed(evt.params.messageid)
    }, 500)
  }

  // Once the login window is closed, we can try and get a token for the resource
  afterLoginWindowClosed(messageId) {
    console.debug("Done waiting on the login window")
    const probeService = this.resources[messageId].probeService
    const accessService = this.findAccessService(probeService)

    this.initiateTokenRequest(accessService, messageId)
  }


  authDenied(authResponse) {
    // This event will lead to the banner message and locked icon being displayed
    const event = new CustomEvent('auth-denied', { detail: { authResponse } } )
    window.dispatchEvent(event)
  }
}
