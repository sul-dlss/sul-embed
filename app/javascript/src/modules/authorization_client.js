const PERMITTED_ORIGINS = [
  "https://stacks.stanford.edu",
  "https://sul-stacks-stage.stanford.edu",
  "https://stacks-uat.stanford.edu",
]
const TIMEOUT = 30000

export function manifestResources(manifest) {
  return (manifest.items || []).flatMap(canvas => [
    ...(canvas.items || []).flatMap(page =>
      (page.items || [])
        .filter(item => item.motivation === "painting")
        .map(item => item.body),
    ),
    ...(canvas.rendering || []),
  ])
}

// One client owns one selected resource. Check every async continuation even
// when a fetch implementation ignores cancellation.
export default class AuthorizationClient {
  constructor({ tokenStore, onResult }) {
    this.tokenStore = tokenStore
    this.onResult = onResult
  }

  current(attempt) {
    return !this.disposed && this.attempt === attempt
  }

  report(attempt, result) {
    if (this.current(attempt)) this.onResult(result)
  }

  authorize(resource) {
    this.cancel()
    if (this.disposed || !resource) return
    const attempt = {
      resource,
      messageId: crypto.randomUUID(),
      abort: new AbortController(),
    }
    this.attempt = attempt
    return this.check(attempt).catch(error => this.fail(attempt, error))
  }

  async check(attempt) {
    const { resource } = attempt
    if (!resource.service) {
      this.report(attempt, { type: "authorized", fileUri: resource.id })
      return
    }
    attempt.probe = resource.service.find(
      service => service.type === "AuthProbeService2",
    )
    if (!attempt.probe) return // Legacy image services belong to their viewer.
    const initial = await this.probe(attempt)
    if (!this.current(attempt) || this.handleProbe(attempt, initial)) return
    const token = this.tokenStore.get()
    if (token) {
      const response = await this.probe(attempt, token)
      const loggedIn = initial.heading?.en?.[0]?.includes("log in")
      if (
        !this.current(attempt) ||
        this.handleProbe(attempt, response, loggedIn)
      )
        return
    }
    attempt.access = this.service(attempt.probe, "AuthAccessService2")
    if (attempt.access.profile === "active") this.needsLogin(attempt)
    else this.requestToken(attempt)
  }

  service(parent, type) {
    const service = parent.service?.find(item => item.type === type)
    if (!service) throw new Error("No " + type + " found")
    return service
  }

  async probe(attempt, token) {
    const timer = setTimeout(() => attempt.abort.abort(), TIMEOUT)
    attempt.requestTimer = timer
    try {
      const response = await fetch(attempt.probe.id, {
        headers: token ? { Authorization: "Bearer " + token } : {},
        signal: attempt.abort.signal,
      })
      return await response.json()
    } finally {
      clearTimeout(timer)
    }
  }

  handleProbe(attempt, response, loggedIn = false) {
    if (response.status === 200 || response.status === 302) {
      this.report(attempt, {
        type: "authorized",
        fileUri: attempt.resource.id,
        location: response.location?.id,
        loggedIn,
      })
      return true
    }
    if (response.status === 403) {
      this.report(attempt, { type: "denied", authResponse: response })
      return true
    }
    if (response.status !== 401)
      throw new Error("Unexpected probe status: " + response.status)
    return false
  }

  needsLogin(attempt) {
    attempt.awaitingLogin = true
    this.report(attempt, {
      type: "login",
      activeAccessService: attempt.access,
      messageId: attempt.messageId,
    })
  }

  login(messageId) {
    const attempt = this.attempt
    if (
      !attempt ||
      !this.current(attempt) ||
      attempt.messageId !== messageId ||
      !attempt.awaitingLogin
    )
      return
    attempt.awaitingLogin = false
    // A previous timed-out probe must not poison a user-initiated retry.
    attempt.abort = new AbortController()
    attempt.popup = window.open(attempt.access.id)
    if (!attempt.popup) {
      this.fail(attempt, new Error("Login popup was blocked"))
      return
    }
    const start = Date.now()
    attempt.poll = setInterval(() => {
      if (!attempt.popup.closed && Date.now() - start < TIMEOUT) return
      this.closePopup(attempt)
      try {
        this.requestToken(attempt)
      } catch (error) {
        this.fail(attempt, error)
      }
    }, 500)
  }

  requestToken(attempt) {
    if (!this.current(attempt)) return
    this.clearTokenRequest(attempt)
    const tokenService = this.service(attempt.access, "AuthAccessTokenService2")
    const url = new URL(tokenService.id)
    if (!PERMITTED_ORIGINS.includes(url.origin))
      throw new Error("Untrusted token service origin")
    url.searchParams.set("messageId", attempt.messageId)
    url.searchParams.set("origin", window.origin)
    const iframe = document.createElement("iframe")
    iframe.hidden = true
    iframe.src = url.href
    attempt.iframe = iframe
    attempt.listener = event => {
      if (
        !this.current(attempt) ||
        event.origin !== url.origin ||
        event.source !== iframe.contentWindow ||
        event.data?.messageId !== attempt.messageId
      )
        return
      const data = event.data
      if (
        data.type !== "AuthAccessTokenError2" &&
        (typeof data.accessToken !== "string" ||
          !data.accessToken ||
          !Number.isFinite(data.expiresIn) ||
          data.expiresIn <= 0)
      )
        return
      this.clearTokenRequest(attempt)
      if (data.type === "AuthAccessTokenError2") {
        this.fail(
          attempt,
          new Error("Access token service rejected the request"),
        )
        return
      }
      this.tokenStore.set(data.accessToken, data.expiresIn)
      this.probe(attempt, data.accessToken)
        .then(response => {
          if (!this.current(attempt)) return
          if (!this.handleProbe(attempt, response, true))
            this.needsLogin(attempt)
        })
        .catch(error => this.fail(attempt, error))
    }
    window.addEventListener("message", attempt.listener)
    attempt.tokenTimer = setTimeout(
      () => this.fail(attempt, new Error("Token request timed out")),
      TIMEOUT,
    )
    document.body.appendChild(iframe)
  }

  clearTokenRequest(attempt) {
    window.removeEventListener("message", attempt.listener)
    clearTimeout(attempt.tokenTimer)
    attempt.iframe?.remove()
    attempt.iframe = null
  }

  closePopup(attempt) {
    clearInterval(attempt.poll)
    attempt.poll = null
    attempt.popup?.close()
    attempt.popup = null
  }

  fail(attempt, error) {
    if (!this.current(attempt)) return
    attempt.abort.abort()
    clearTimeout(attempt.requestTimer)
    this.clearTokenRequest(attempt)
    this.closePopup(attempt)
    this.report(attempt, { type: "error", error })
    if (attempt.access) this.needsLogin(attempt)
  }

  cancel() {
    const attempt = this.attempt
    this.attempt = null
    if (!attempt) return
    attempt.abort.abort()
    clearTimeout(attempt.requestTimer)
    this.clearTokenRequest(attempt)
    this.closePopup(attempt)
  }

  dispose() {
    this.cancel()
    this.disposed = true
  }
}
