import Mirador from "mirador"
import { miradorImageToolsPlugin } from "mirador-image-tools"
import {
  miradorSharePlugin,
  miradorShareDialogPlugin,
} from "mirador-share-plugin"
import {
  miradorDownloadPlugin,
  miradorDownloadDialogPlugin,
} from "mirador-dl-plugin"

import { sulTheme, viewerViews, defaultWorkspace } from "@/mirador/config.js"
import { handleViewerPostMessage } from "@/mirador/postMessageHandler.js"
import { keepRequestedCanvasThroughInitialSearch } from "@/mirador/initialSearchCanvas.js"

import comparisonPlugin from "@/mirador/plugins/comparisonPlugin.jsx"
import analyticsPlugin from "@/mirador/plugins/analyticsPlugin.js"
import xywhPlugin from "@/mirador/plugins/xywhPlugin.js"
import customMenuPlugin from "@/mirador/plugins/customMenuPlugin.jsx"
import georeferencePlugin from "@/mirador/plugins/georeferencePlugin.jsx"

export default {
  init: function () {
    const el = document.getElementById("sul-embed-mirador")
    const data = el.dataset

    const showAttribution = data.showAttribution === "true"
    const hideWindowTitle = data.hideTitle === "true"
    const enableComparison = data.enableComparison === "true"
    // Set when the object carries a georeference annotation, which says where on a map the scan
    // belongs. The scan is still what the object is, so the map joins it as a second view of the
    // same window rather than replacing it or living in a viewer of its own.
    const georeferenceUrl = data.georeferenceUrl

    // Determine which sidebar panel to show
    let sideBarPanel = "info"
    if (data.search?.length > 0) sideBarPanel = "search"
    if (showAttribution) sideBarPanel = "attribution"

    // An embed that asks for both a starting canvas and a search term wants to
    // land on that canvas with the term highlighted, but Mirador would jump to
    // the first hit in the document instead. See initialSearchCanvas.js.
    const searchWithinRequestedCanvas =
      data.search?.length > 0 && Boolean(data.canvasId || data.canvasIndex)

    const viewerInstance = Mirador.viewer(
      {
        id: "sul-embed-mirador",
        selectedTheme: "sul",
        themes: sulTheme,
        windows: [
          {
            id: "main",
            ...(searchWithinRequestedCanvas && {
              switchCanvasOnSearch: false,
            }),
            loadedManifest: data.miradorUri,
            canvasIndex: Number(data.canvasIndex),
            canvasId: data.canvasId,
            defaultSearchQuery:
              data.search?.length > 0 ? data.search : undefined,
            suggestedSearches:
              data.suggestedSearch?.length > 0 ? [data.suggestedSearch] : null,
            ...(data.viewerConfig && {
              initialViewerConfig: JSON.parse(data.viewerConfig),
            }),
          },
        ],
        window: {
          allowClose: false,
          allowFullscreen: true,
          allowMaximize: false,
          authNewWindowCenter: "screen",
          sideBarPanel,
          hideWindowTitle,
          sideBarOpen: showAttribution || data.search?.length > 0,
          panels: {
            annotations: true,
            layers: true,
            search: true,
          },
          imageToolsEnabled: true,
          imageToolsOpen: false,
          views: viewerViews,
        },
        workspace: defaultWorkspace(enableComparison),
        workspaceControlPanel: {
          enabled: false,
        },
        miradorSharePlugin: {
          embedOption: {
            enabled: true,
            embedUrlReplacePattern: [
              /.*\.edu\/(\w+)\/iiif\d?\/manifest/,
              "https://embed.stanford.edu/iframe?url=https://purl.stanford.edu/$1",
            ],
          },
          dragAndDropInfoLink: "https://library.stanford.edu/iiif",
          shareLink: {
            enabled: true,
            manifestIdReplacePattern: [
              /(purl.*.stanford.edu.*)\/iiif\d?\/manifest(.json)?$/,
              "$1",
            ],
          },
        },
        miradorDownloadPlugin: {
          restrictDownloadOnSizeDefinition: true,
        },
      },
      [
        ...(enableComparison ? comparisonPlugin : []),
        ...(georeferenceUrl
          ? [
              georeferencePlugin({
                annotationUrl: georeferenceUrl,
                manifestUrl: data.iiif3Manifest,
                labels: JSON.parse(data.viewLabels),
              }),
            ]
          : []),
        analyticsPlugin,
        xywhPlugin,
        customMenuPlugin,
        ...miradorImageToolsPlugin,
        { ...miradorSharePlugin, target: "CustomMenuComponent" },
        miradorShareDialogPlugin,
        { ...miradorDownloadPlugin, target: "CustomMenuComponent" },
        miradorDownloadDialogPlugin,
      ],
    )

    if (searchWithinRequestedCanvas) {
      keepRequestedCanvasThroughInitialSearch(viewerInstance.store, "main")
    }

    handleViewerPostMessage(viewerInstance)
  },
}
