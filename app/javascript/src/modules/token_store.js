// Preserve the cache format consumed by other viewers.
export default class TokenStore {
  constructor({
    storage = () => window.localStorage,
    now = () => Date.now(),
  } = {}) {
    this.storage = storage
    this.now = now
  }

  get() {
    try {
      const value = JSON.parse(this.storage().getItem("accessToken"))
      if (
        typeof value?.accessToken === "string" &&
        value.accessToken &&
        new Date(value.expires).getTime() > this.now()
      )
        return value.accessToken
    } catch {
      // Storage may be disabled or malformed.
    }
    this.clear()
    return null
  }

  set(accessToken, expiresIn) {
    if (
      typeof accessToken !== "string" ||
      !accessToken ||
      !Number.isFinite(expiresIn) ||
      expiresIn <= 0
    )
      return
    try {
      const expires = new Date(this.now() + expiresIn * 1000).toISOString()
      this.storage().setItem(
        "accessToken",
        JSON.stringify({ accessToken, expires }),
      )
    } catch {
      // Authorization still works without persistent storage.
    }
  }

  clear() {
    try {
      this.storage().removeItem("accessToken")
    } catch {
      // Storage may be disabled.
    }
  }
}
