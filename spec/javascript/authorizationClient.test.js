// @vitest-environment-options {"settings":{"navigation":{"disableChildFrameNavigation":true}}}
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"
import AuthorizationClient, {
  manifestResources,
} from "@/modules/authorization_client"

const origin = "https://stacks.stanford.edu"
const access = {
  type: "AuthAccessService2",
  profile: "active",
  id: origin + "/login",
  service: [
    { type: "AuthAccessTokenService2", id: origin + "/token?existing=yes" },
  ],
}
const resource = {
  id: origin + "/file",
  service: [
    { type: "AuthProbeService2", id: origin + "/probe", service: [access] },
  ],
}
const restricted = { status: 401, heading: { en: ["Please log in"] } }
const response = json => ({ json: async () => json })

describe("AuthorizationClient", () => {
  let client, onResult, tokenStore, fetchMock
  beforeEach(() => {
    vi.useFakeTimers()
    onResult = vi.fn()
    tokenStore = { get: vi.fn(), set: vi.fn() }
    fetchMock = vi.fn()
    vi.stubGlobal("fetch", fetchMock)
    client = new AuthorizationClient({ tokenStore, onResult })
  })
  afterEach(() => {
    client.dispose()
    vi.restoreAllMocks()
    vi.unstubAllGlobals()
    vi.useRealTimers()
  })

  async function requestToken() {
    fetchMock.mockResolvedValueOnce(response(restricted))
    await client.authorize(resource)
    const messageId = onResult.mock.lastCall[0].messageId
    const popup = { closed: true, close: vi.fn() }
    vi.spyOn(window, "open").mockReturnValue(popup)
    client.login(messageId)
    await vi.advanceTimersByTimeAsync(500)
    const iframe = document.querySelector("iframe")
    expect(iframe.contentWindow).not.toBeNull()
    return { iframe, messageId, popup }
  }

  function message(iframe, messageId, overrides = {}) {
    window.dispatchEvent(
      new MessageEvent("message", {
        origin,
        source: iframe.contentWindow,
        data: { messageId, accessToken: "new-token", expiresIn: 60 },
        ...overrides,
      }),
    )
  }

  it("extracts painting and rendering resources and tolerates an empty manifest", () => {
    expect(
      manifestResources({
        items: [
          {
            items: [
              {
                items: [
                  { motivation: "painting", body: resource },
                  { motivation: "commenting", body: { id: "skip" } },
                ],
              },
            ],
            rendering: [{ id: "map" }],
          },
        ],
      }),
    ).toEqual([resource, { id: "map" }])
    expect(manifestResources({})).toEqual([])
  })

  it("authorizes a public resource without network activity", async () => {
    await client.authorize({ id: "public" })
    expect(onResult).toHaveBeenCalledWith({
      type: "authorized",
      fileUri: "public",
    })
    expect(fetchMock).not.toHaveBeenCalled()
  })

  it("probes anonymously before using a cached token and preserves the authorized location", async () => {
    tokenStore.get.mockReturnValue("cached")
    fetchMock
      .mockResolvedValueOnce(response(restricted))
      .mockResolvedValueOnce(
        response({ status: 302, location: { id: "redirect" } }),
      )
    await client.authorize(resource)
    expect(fetchMock.mock.calls[0][1].headers).toEqual({})
    expect(fetchMock.mock.calls[1][1].headers).toEqual({
      Authorization: "Bearer cached",
    })
    expect(onResult).toHaveBeenCalledWith({
      type: "authorized",
      fileUri: resource.id,
      location: "redirect",
      loggedIn: true,
    })
  })

  it("does not start login for a forbidden resource", async () => {
    fetchMock.mockResolvedValue(response({ status: 403 }))
    await client.authorize(resource)
    expect(onResult).toHaveBeenCalledWith({
      type: "denied",
      authResponse: { status: 403 },
    })
    expect(tokenStore.get).not.toHaveBeenCalled()
  })

  it("accepts only the matching iframe, origin and message id, and removes the listener after use", async () => {
    const { iframe, messageId } = await requestToken()
    const url = new URL(iframe.src)
    expect(url.searchParams.get("existing")).toBe("yes")
    expect(url.searchParams.get("origin")).toBe(window.origin)
    message(iframe, messageId, { origin: "https://example.com" })
    message(iframe, messageId, { source: window })
    message(iframe, "wrong")
    message(iframe, messageId, { data: null })
    expect(tokenStore.set).not.toHaveBeenCalled()
    const source = iframe.contentWindow
    fetchMock.mockResolvedValueOnce(response({ status: 200 }))
    message(iframe, messageId)
    await vi.advanceTimersByTimeAsync(0)
    expect(tokenStore.set).toHaveBeenCalledExactlyOnceWith("new-token", 60)
    expect(iframe.isConnected).toBe(false)
    expect(onResult.mock.lastCall[0].type).toBe("authorized")
    message(iframe, messageId, { source })
    expect(tokenStore.set).toHaveBeenCalledTimes(1)
    expect(vi.getTimerCount()).toBe(0)
  })

  it("reports token errors and allows login again", async () => {
    const { iframe, messageId } = await requestToken()
    message(iframe, messageId, {
      data: { messageId, type: "AuthAccessTokenError2" },
    })
    expect(onResult).toHaveBeenCalledWith({
      type: "error",
      error: expect.any(Error),
    })
    expect(onResult.mock.lastCall[0].type).toBe("login")
    expect(iframe.isConnected).toBe(false)
    expect(tokenStore.set).not.toHaveBeenCalled()
  })

  it("times out a token request and removes its iframe and listener", async () => {
    const { iframe, messageId } = await requestToken()
    const source = iframe.contentWindow
    await vi.advanceTimersByTimeAsync(30000)
    expect(iframe.isConnected).toBe(false)
    message(iframe, messageId, { source })
    expect(tokenStore.set).not.toHaveBeenCalled()
    expect(onResult).toHaveBeenCalledWith({
      type: "error",
      error: expect.any(Error),
    })
    expect(vi.getTimerCount()).toBe(0)
  })

  it("aborts and ignores a late probe after another resource is selected", async () => {
    let resolve
    fetchMock.mockReturnValue(
      new Promise(done => {
        resolve = done
      }),
    )
    const pending = client.authorize(resource)
    const signal = fetchMock.mock.calls[0][1].signal
    await client.authorize({ id: "other" })
    expect(signal.aborted).toBe(true)
    resolve(response({ status: 200 }))
    await pending
    expect(onResult).toHaveBeenCalledExactlyOnceWith({
      type: "authorized",
      fileUri: "other",
    })
  })

  it("aborts pending requests on disposal without reporting an error", async () => {
    fetchMock.mockImplementation(
      (url, { signal }) =>
        new Promise((resolve, reject) => {
          signal.addEventListener("abort", () =>
            reject(new DOMException("Aborted", "AbortError")),
          )
        }),
    )
    const pending = client.authorize(resource)
    client.dispose()
    await pending
    expect(onResult).not.toHaveBeenCalled()
    expect(vi.getTimerCount()).toBe(0)
  })

  it("closes popups and clears polling on disposal", async () => {
    fetchMock.mockResolvedValue(response(restricted))
    await client.authorize(resource)
    const popup = { closed: false, close: vi.fn() }
    vi.spyOn(window, "open").mockReturnValue(popup)
    client.login(onResult.mock.lastCall[0].messageId)
    client.dispose()
    expect(popup.close).toHaveBeenCalledOnce()
    expect(vi.getTimerCount()).toBe(0)
    expect(document.querySelector("iframe")).toBeNull()
  })

  it("removes pending token requests on disposal and ignores subsequent messages", async () => {
    const { iframe, messageId } = await requestToken()
    const source = iframe.contentWindow
    client.dispose()
    message(iframe, messageId, { source })
    expect(iframe.isConnected).toBe(false)
    expect(tokenStore.set).not.toHaveBeenCalled()
    expect(vi.getTimerCount()).toBe(0)
  })

  it("reports network errors without treating them as a login challenge", async () => {
    fetchMock.mockRejectedValue(new Error("Offline"))
    await client.authorize(resource)
    expect(onResult).toHaveBeenCalledExactlyOnceWith({
      type: "error",
      error: expect.any(Error),
    })
  })

  it("requests a token directly for a passive access service after a cached token is rejected", async () => {
    tokenStore.get.mockReturnValue("expired-on-server")
    fetchMock.mockResolvedValue(response(restricted))
    const passive = {
      ...resource,
      service: [
        {
          ...resource.service[0],
          service: [{ ...access, profile: "external" }],
        },
      ],
    }
    await client.authorize(passive)
    expect(fetchMock).toHaveBeenCalledTimes(2)
    expect(document.querySelector("iframe")).not.toBeNull()
    expect(onResult).not.toHaveBeenCalled()
  })

  it("aborts a stalled probe at its deadline", async () => {
    fetchMock.mockImplementation(
      (url, { signal }) =>
        new Promise((resolve, reject) => {
          signal.addEventListener("abort", () =>
            reject(new DOMException("Aborted", "AbortError")),
          )
        }),
    )
    const pending = client.authorize(resource)
    await vi.advanceTimersByTimeAsync(30000)
    await pending
    expect(fetchMock.mock.calls[0][1].signal.aborted).toBe(true)
    expect(onResult).toHaveBeenCalledExactlyOnceWith({
      type: "error",
      error: expect.any(Error),
    })
    expect(vi.getTimerCount()).toBe(0)
  })

  it("stops popup polling at the deadline and proceeds to the token service", async () => {
    fetchMock.mockResolvedValue(response(restricted))
    await client.authorize(resource)
    const popup = { closed: false, close: vi.fn() }
    vi.spyOn(window, "open").mockReturnValue(popup)
    client.login(onResult.mock.lastCall[0].messageId)
    await vi.advanceTimersByTimeAsync(30000)
    expect(popup.close).toHaveBeenCalledOnce()
    expect(document.querySelector("iframe")).not.toBeNull()
    client.dispose()
    expect(vi.getTimerCount()).toBe(0)
  })

  it("reports blocked popups and offers another login attempt without a timer", async () => {
    fetchMock.mockResolvedValue(response(restricted))
    await client.authorize(resource)
    vi.spyOn(window, "open").mockReturnValue(null)
    client.login(onResult.mock.lastCall[0].messageId)
    expect(onResult).toHaveBeenCalledWith({
      type: "error",
      error: expect.any(Error),
    })
    expect(onResult.mock.lastCall[0].type).toBe("login")
    expect(vi.getTimerCount()).toBe(0)
  })
})
