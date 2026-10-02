import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"
import { Storage } from "happy-dom"
import TokenStore from "@/modules/token_store"

describe("TokenStore", () => {
  beforeEach(() => vi.stubGlobal("localStorage", new Storage()))
  afterEach(() => vi.unstubAllGlobals())

  it("expires tokens and removes only its own cache entry", () => {
    let now = 100000
    const store = new TokenStore({ now: () => now })
    window.localStorage.setItem("unrelated", "keep")
    store.set("token", 10)
    expect(store.get()).toBe("token")
    now += 10000
    expect(store.get()).toBeNull()
    expect(window.localStorage.getItem("accessToken")).toBeNull()
    expect(window.localStorage.getItem("unrelated")).toBe("keep")
  })

  it("recovers from malformed storage without clearing other preferences", () => {
    window.localStorage.setItem("accessToken", "{bad")
    window.localStorage.setItem("unrelated", "keep")
    expect(new TokenStore().get()).toBeNull()
    expect(window.localStorage.getItem("unrelated")).toBe("keep")
  })

  it("tolerates browsers that deny access to storage", () => {
    const store = new TokenStore({
      storage: () => {
        throw new Error("Denied")
      },
    })
    expect(store.get()).toBeNull()
    expect(() => store.set("token", 30)).not.toThrow()
  })

  it("does not persist malformed tokens or expiration times", () => {
    const storage = { setItem: vi.fn() }
    const store = new TokenStore({ storage: () => storage })
    store.set("", 10)
    store.set("token", NaN)
    store.set("token", -1)
    expect(storage.setItem).not.toHaveBeenCalled()
  })
})
