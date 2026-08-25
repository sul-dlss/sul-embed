import { useEffect, useRef, useState } from "react"
import { styled } from "@mui/material/styles"
import Tab from "@mui/material/Tab"
import Tabs from "@mui/material/Tabs"
import Typography from "@mui/material/Typography"

// Which view is showing. The same keys the titles are filed under in en.yml, under
// viewers.mirador_viewer.views - see MiradorViewer#view_labels.
const IMAGE = "image"
const MAP = "map"

// This sits where Mirador's image viewer sat, which is a flex child of the primary window alongside
// the sidebar, so it fills the same space and stacks the tab strip above what it shows.
const Root = styled("div", { name: "SulGeoreference", slot: "root" })({
  display: "flex",
  flex: 1,
  flexDirection: "column",
  minHeight: 0,
})

// Once a view has been opened it stays mounted and is hidden rather than unmounted, so going back to
// it doesn't throw away OpenSeadragon's tiles or the map's camera position. A column, because what
// goes inside is a flex child asking to grow.
const View = styled("div", { name: "SulGeoreference", slot: "view" })({
  display: "flex",
  flex: 1,
  flexDirection: "column",
  minHeight: 0,
  position: "relative",
})

// The scan projected onto a map, drawn by ogm-viewer from the record's georeference annotation.
const MapView = ({ annotationUrl, manifestUrl }) => {
  const ref = useRef(null)
  const [failed, setFailed] = useState(false)

  useEffect(() => {
    let live = true

    const draw = async () => {
      // Imported here rather than at the top of the file so Vite gives it a chunk of its own: the
      // viewer is around a megabyte gzipped, and most people looking at a scanned map never ask to
      // see it on a map. The first import defines the elements, the second hands back the classes
      // they use internally.
      const [, lib] = await Promise.all([
        import("ogm-viewer"),
        import("ogm-viewer/lib"),
      ])

      // The manifest first and the shelved annotation as the fallback, which is the order ogm-viewer
      // reads them in: a manifest generated at request time carries the more current copy.
      const resource = new lib.IIIFManifestResource(
        "sul-embed-georeference",
        manifestUrl,
        undefined,
        undefined,
        annotationUrl,
      )

      const previewer = (await lib.previewersFor(resource)).find(
        candidate => candidate.renderer === "map",
      )
      if (!previewer) throw new Error("nothing here draws a map")

      // A DOM property, never an attribute - a previewer is an object. Set once the element has
      // mounted, because assigning before the map has its style reaches addSource() too early.
      await customElements.whenDefined("ogm-preview")
      if (!live || !ref.current) return

      await ref.current.componentOnReady?.()
      if (!live || !ref.current) return

      ref.current.theme = "light"
      ref.current.previewer = previewer
    }

    draw().catch(error => {
      if (!live) return
      console.error("Could not show this scan on a map:", error)
      setFailed(true)
    })

    return () => {
      live = false
    }
  }, [annotationUrl, manifestUrl])

  if (failed) {
    return (
      <Typography sx={{ margin: 2 }} variant="body1">
        This scan couldn&apos;t be shown on a map.
      </Typography>
    )
  }

  return <ogm-preview ref={ref} style={{ flex: 1, minHeight: 0 }} />
}

// Wraps Mirador's image viewer in a tab strip, so a georeferenced scan can be read as pages or seen
// in place without leaving the viewer. The image viewer rather than the whole primary window, which
// is what holds the sidebar and the companion areas: hiding those to show the map would leave the
// window's own sidebar button doing nothing.
export default function georeferencePlugin({
  annotationUrl,
  labels,
  manifestUrl,
}) {
  const GeoreferenceViews = ({ children }) => {
    const [view, setView] = useState(IMAGE)
    const [mapOpened, setMapOpened] = useState(false)

    const select = (_event, chosen) => {
      setView(chosen)
      if (chosen === MAP) setMapOpened(true)
    }

    return (
      <Root>
        <Tabs
          aria-label="Ways to view this map"
          // MUI puts aria-label on the inner list and styles the root, so the root needs a hook of
          // its own for anything wanting to talk about the strip as a whole.
          className="sul-view-tabs"
          onChange={select}
          sx={{
            // A surface of its own, the same one the window's top bar uses. Left transparent it sits
            // on the dark backdrop Mirador puts behind an image, where its own labels can't be read.
            backgroundColor: "shades.main",
            borderBottom: 1,
            borderColor: "divider",
            // MUI upper-cases tab labels; Mirador's own view names ("Single", "Gallery") are
            // sentence case, so these read as written rather than shouted.
            "& .MuiTab-root": { textTransform: "none" },
            flex: "0 0 auto",
            minHeight: 0,
          }}
          value={view}
        >
          <Tab label={labels[IMAGE]} value={IMAGE} />
          <Tab label={labels[MAP]} value={MAP} />
        </Tabs>

        <View style={{ display: view === IMAGE ? "flex" : "none" }}>
          {children}
        </View>

        {mapOpened && (
          <View style={{ display: view === MAP ? "flex" : "none" }}>
            <MapView annotationUrl={annotationUrl} manifestUrl={manifestUrl} />
          </View>
        )}
      </Root>
    )
  }

  return {
    target: "WindowViewer",
    mode: "wrap",
    name: "SulGeoreferencePlugin",
    component: GeoreferenceViews,
  }
}
