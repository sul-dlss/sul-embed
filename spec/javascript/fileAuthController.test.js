import FileAuthController from "../../app/javascript/controllers/file_auth_controller.js"

// Shaped like https://purl.stanford.edu/km424vv8152/iiif3/manifest: a media object whose PDF
// transcript gets no canvas of its own and is published as a manifest level rendering resource.
const AUDIO = {
  id: "https://stacks.stanford.edu/file/km424vv8152/audio_sl.m4a",
  format: "audio/mp4",
}
const PHOTO = {
  id: "https://stacks.stanford.edu/image/iiif/km424vv8152%2Fphoto/full/full/0/default.jpg",
  format: "image/jpeg",
}
const JP2 = {
  id: "https://stacks.stanford.edu/file/km424vv8152/photo.jp2",
  format: "image/jp2",
}
const TRANSCRIPT = {
  id: "https://stacks.stanford.edu/file/km424vv8152/transcript.pdf",
  format: "application/pdf",
}

const manifest = {
  items: [
    {
      items: [{ items: [{ motivation: "painting", body: AUDIO }] }],
    },
    {
      items: [{ items: [{ motivation: "painting", body: PHOTO }] }],
      rendering: [JP2],
    },
  ],
  rendering: [TRANSCRIPT],
}

const buildController = () => {
  const controller = Object.create(FileAuthController.prototype)
  controller.addPostCallbackListener = vi.fn()
  controller.maybeDrawContentResource = vi.fn()
  return controller
}

describe("FileAuthController", () => {
  describe("parseFiles", () => {
    it("collects painting bodies and canvas level rendering resources", () => {
      const controller = buildController()
      controller.parseFiles({ detail: manifest })

      expect(controller.documents).toContain(AUDIO)
      expect(controller.documents).toContain(PHOTO)
      expect(controller.documents).toContain(JP2)
    })

    it("collects manifest level rendering resources, which have no canvas of their own", () => {
      const controller = buildController()
      controller.parseFiles({ detail: manifest })

      expect(controller.documents).toContain(TRANSCRIPT)
    })

    it("tolerates a manifest with no rendering resources", () => {
      const controller = buildController()
      controller.parseFiles({ detail: { items: manifest.items } })

      expect(controller.documents).toEqual([AUDIO, PHOTO, JP2])
    })
  })

  describe("selectedDocument", () => {
    it("opens on the first canvas when the viewer named no file", () => {
      const controller = buildController()
      controller.parseFiles({ detail: manifest })

      expect(controller.maybeDrawContentResource).toHaveBeenCalledWith(AUDIO)
    })

    it("opens on the file the viewer named", () => {
      const controller = buildController()
      controller.selectedFileUrlValue = TRANSCRIPT.id
      controller.hasSelectedFileUrlValue = true
      controller.parseFiles({ detail: manifest })

      expect(controller.maybeDrawContentResource).toHaveBeenCalledWith(
        TRANSCRIPT,
      )
    })

    it("falls back to the first canvas when the named file is not in the manifest", () => {
      const controller = buildController()
      controller.selectedFileUrlValue = "https://example.com/missing.pdf"
      controller.hasSelectedFileUrlValue = true
      controller.parseFiles({ detail: manifest })

      expect(controller.maybeDrawContentResource).toHaveBeenCalledWith(AUDIO)
    })
  })

  describe("authFileAndDisplay", () => {
    it("draws a manifest level rendering resource when its thumbnail is clicked", () => {
      const controller = buildController()
      controller.parseFiles({ detail: manifest })
      controller.maybeDrawContentResource.mockClear()

      controller.authFileAndDisplay({ detail: { fileUri: TRANSCRIPT.id } })

      expect(controller.maybeDrawContentResource).toHaveBeenCalledWith(
        TRANSCRIPT,
      )
    })
  })

  describe("handlePostCallback", () => {
    it("ignores unrelated messages from a permitted origin", () => {
      const controller = buildController()
      controller.handlePostCallback({
        origin: "https://stacks.stanford.edu",
        data: { cmd: "setTEIdentifier", teIdentifier: "abc123" },
      })

      expect(controller.iframe).toBeUndefined()
    })

    it("handles a token response for a requested resource", async () => {
      const controller = buildController()
      const iframe = document.createElement("iframe")
      document.body.appendChild(iframe)
      controller.iframe = iframe
      controller.resources = { message123: {} }
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
})
