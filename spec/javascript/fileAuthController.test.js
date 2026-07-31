import { beforeEach, describe, expect, it, vi } from "vitest"

const { default: FileAuthController } =
  await import("../../app/javascript/controllers/file_auth_controller.js")

describe("FileAuthController", () => {
  let controller

  beforeEach(() => {
    controller = Object.create(FileAuthController.prototype)
    controller.resources = {}
  })

  it("ignores unrelated messages from a permitted origin", () => {
    controller.handlePostCallback({
      origin: "https://stacks.stanford.edu",
      data: { cmd: "setTEIdentifier", teIdentifier: "abc123" },
    })

    expect(controller.iframe).toBeUndefined()
  })

  it("handles a token response for a requested resource", async () => {
    const iframe = document.createElement("iframe")
    document.body.appendChild(iframe)
    controller.iframe = iframe
    controller.resources.message123 = {}
    controller.cacheToken = vi.fn()
    controller.queryProbeService = vi.fn().mockResolvedValue({
      fileUri: "https://stacks.stanford.edu/file/example.pdf",
    })
    controller.renderViewer = vi.fn()

    controller.handlePostCallback({
      origin: "https://stacks.stanford.edu",
      data: {
        type: "AuthAccessToken2",
        messageId: "message123",
        accessToken: "token",
        expiresIn: 300,
      },
    })
    await vi.waitFor(() => expect(controller.renderViewer).toHaveBeenCalled())

    expect(iframe).not.toBeInTheDocument()
    expect(controller.cacheToken).toHaveBeenCalledWith("token", 300)
    expect(controller.queryProbeService).toHaveBeenCalledWith(
      "message123",
      "token",
    )
  })
})
