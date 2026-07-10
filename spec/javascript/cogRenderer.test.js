import { beforeEach, describe, expect, it, vi } from "vitest"

const { CogRenderer, CredentialedHttpSource } =
  await import("../../app/javascript/geo/cog_renderer.js")

describe("CredentialedHttpSource", () => {
  beforeEach(() => {
    globalThis.fetch = vi.fn()
  })

  it("fetches HEAD metadata with credentials", async () => {
    fetch.mockResolvedValue(
      new Response(null, {
        status: 200,
        headers: {
          "content-length": "1234",
          etag: "abc123",
          "content-type": "image/tiff",
        },
      }),
    )

    const source = new CredentialedHttpSource(
      "https://stacks.stanford.edu/file/abc/data.tif",
    )
    const metadata = await source.head()

    expect(fetch).toHaveBeenCalledWith(source.url, {
      method: "HEAD",
      credentials: "include",
    })
    expect(metadata).toMatchObject({
      size: 1234,
      eTag: "abc123",
      contentType: "image/tiff",
    })
  })

  it("fetches byte ranges with credentials", async () => {
    const buffer = new ArrayBuffer(8)
    const signal = AbortSignal.abort()
    fetch.mockResolvedValue(
      new Response(buffer, {
        status: 206,
        headers: {
          "content-range": "bytes 10-17/1234",
          etag: "abc123",
        },
      }),
    )

    const source = new CredentialedHttpSource(
      "https://stacks.stanford.edu/file/abc/data.tif",
    )
    const response = await source.fetch(10, 8, { signal })

    expect(fetch).toHaveBeenCalledWith(source.url, {
      headers: { Range: "bytes=10-17" },
      signal,
      credentials: "include",
    })
    expect(response.byteLength).toBe(8)
    expect(source.metadata).toMatchObject({ size: 1234, eTag: "abc123" })
  })
})

describe("CogRenderer", () => {
  let COGLayer
  let MapboxOverlay
  let GeoTIFF
  let overlay
  let map

  beforeEach(() => {
    COGLayer = vi.fn(function FakeCOGLayer(props) {
      this.props = props
    })
    GeoTIFF = {
      open: vi.fn().mockResolvedValue("opened-geotiff"),
    }
    overlay = {
      setProps: vi.fn(),
    }
    MapboxOverlay = vi.fn(function FakeMapboxOverlay() {
      return overlay
    })
    map = {
      addControl: vi.fn(),
      fitBounds: vi.fn(),
    }
    window.GeoAssets = {
      DeckMapbox: { MapboxOverlay },
      DeckGlGeotiff: { COGLayer },
      Geotiff: {
        DecoderPool: class FakeDecoderPool {},
        GeoTIFF,
      },
    }
  })

  it("passes public COG URLs directly to the raster layer", () => {
    const renderer = new CogRenderer(
      map,
      "https://stacks.stanford.edu/file/abc/data.tif",
    )

    renderer.render()

    expect(GeoTIFF.open).not.toHaveBeenCalled()
    expect(COGLayer.mock.calls[0][0].geotiff).toBe(
      "https://stacks.stanford.edu/file/abc/data.tif",
    )
  })

  it("opens restricted COG URLs with a credentialed source", () => {
    const renderer = new CogRenderer(
      map,
      "https://stacks.stanford.edu/file/abc/data.tif",
      undefined,
      "token",
    )

    renderer.render()

    expect(GeoTIFF.open).toHaveBeenCalledWith({
      dataSource: expect.any(CredentialedHttpSource),
      headerSource: expect.any(CredentialedHttpSource),
    })
    expect(COGLayer.mock.calls[0][0].geotiff).toBe(
      GeoTIFF.open.mock.results[0].value,
    )
  })
})
