import Mirador, { getExportableState } from 'mirador'
import { miradorImageToolsPlugin } from 'mirador-image-tools'
import { miradorSharePlugin, miradorShareDialog as miradorShareDialogPlugin } from 'mirador-share-plugin'
import { miradorDownloadPlugin, MiradorDownloadDialogPlugin as miradorDownloadDialogPlugin } from 'mirador-dl-plugin'
import { shareMenuPlugin } from '@/plugins/shareMenuPlugin.jsx'
import embedModePlugin from '@/plugins/embedModePlugin.js'
import analyticsPlugin from '@/plugins/analyticsPlugin.js'

export default {
  init: function() {
    const el = document.getElementById('sul-embed-m3')
    const data = el.dataset
    const showAttribution = (data.showAttribution === 'true')
    const hideWindowTitle = (data.hideTitle === 'true')
<<<<<<< HEAD
    const enableComparison = (data.enableComparison === 'true')
    const cdl = (data.cdl === 'true')
=======
    const imageTools = (data.imageTools === 'true')
>>>>>>> 65c5f1a5 (Remove CDL mirador plugins.)

    // Determine which panel should be open
    var sideBarPanel = 'info'
    if (data.search.length > 0) {
      sideBarPanel = 'search'
    }
    if (showAttribution) {
      sideBarPanel = 'attribution'
    }

    const viewerInstance = Mirador.viewer({
      id: 'sul-embed-m3',
      miradorDownloadPlugin: {
        restrictDownloadOnSizeDefinition: true,
      },
      miradorSharePlugin: {
        embedOption: {
          enabled: true,
          embedUrlReplacePattern: [
            /.*\.edu\/(\w+)\/iiif\d?\/manifest/,
            'https://embed.stanford.edu/iframe?url=https://purl.stanford.edu/$1',
          ],
        },
        dragAndDropInfoLink: 'https://library.stanford.edu/iiif',
        shareLink: {
          enabled: true,
          manifestIdReplacePattern: [
            /(purl.*.stanford.edu.*)\/iiif\d?\/manifest(.json)?$/,
            '$1',
          ],
        },
      },
      selectedTheme: 'sul',
      themes: {
        sul: {
          palette: {
            type: 'light',
            primary: {
              main: '#8c1515',
            },
            secondary: {
              main: '#8c1515',
            },
            shades: {
              dark: '#2e2d29',
              main: '#ffffff',
              light: '#f4f4f4',
            },
            notification: {
              main: '#e98300'
            },
          }
        }
      },
      windows: [{
        id: 'main',
        defaultSearchQuery: data.search.length > 0 ? data.search : undefined,
        suggestedSearches: data.suggestedSearch.length > 0 ? [data.suggestedSearch] : null,
        loadedManifest: data.m3Uri,
        canvasIndex: Number(data.canvasIndex),
        ...(data.viewerConfig && { initialViewerConfig: JSON.parse(data.viewerConfig) }),
        canvasId: data.canvasId,
      }],
      window: {
        allowClose: false,
        allowFullscreen: true,
        allowMaximize: false,
        authNewWindowCenter: 'screen',
        sideBarPanel,
        hideWindowTitle: hideWindowTitle,
        panels: {
          annotations: true,
          layers: true,
          search: true,
        },
        sideBarOpen: (showAttribution || data.search.length > 0),
        imageToolsEnabled: true,
        imageToolsOpen: false,
        views: [
          { key: 'single', behaviors: [null, 'individuals'] },
          { key: 'book', behaviors: [null, 'paged'] },
          { key: 'scroll', behaviors: ['continuous'] },
          { key: 'gallery' },
        ],
      },
      workspace: {
        showZoomControls: true,
        type: enableComparison ? 'mosaic' : 'single',
      },
      workspaceControlPanel: {
        enabled: false,
      }
    }, [
      ...miradorImageToolsPlugin,
      // shareMenuPlugin is the customized menu in the top bar containing the share and download plugin buttons
      // shareMenuPlugin exposes the SulEmbedShareMenu component
      shareMenuPlugin,
<<<<<<< HEAD
      miradorZoomBugPlugin,
      ...((enableComparison && embedModePlugin) || []),
=======
      ...((imageTools && embedModePlugin) || []),
>>>>>>> a6b7bab9 (Remove mirador zoom button patch.)
      {
        ...miradorSharePlugin,
        target: 'SulEmbedShareMenu',
      },
      miradorShareDialogPlugin,
      miradorDownloadDialogPlugin,
      {
        ...miradorDownloadPlugin,
        target: 'SulEmbedShareMenu',
      },
      analyticsPlugin,
      xywhPlugin,
    ].filter(Boolean))

    window.addEventListener('message', (event) => {
      const regex = /(stanford\.edu|[\w-]+\.stanford\.edu)/

      if (regex.exec(event.origin) === null && process.env.RAILS_ENV !== 'development') {
        return
      }

      if (event && event.data) {
        let parsedData
        try {
          parsedData = typeof event.data === 'string' ? JSON.parse(event.data) : event.data
        } catch (error) {
          console.error('Failed to parse event data:', error)
          return // Exit if parsing fails
        }
        if (parsedData.type === "requestState") {
          const currentState = viewerInstance.store.getState()
          const exportableState = getExportableState(currentState)

          const imageUrl = viewerInstance.container.querySelector('[data-full-image]').dataset.fullImage.split('*')
          const canvasIndex = viewerInstance.container.querySelector('.mirador-canvas-count').textContent.split(' of')[0]

          // Send the state back to the parent window
          window.parent.postMessage(
            JSON.stringify({
              type: 'stateResponse',
              data: {...exportableState, ...{'iiif_images': imageUrl, 'canvas_index': canvasIndex}},
              source: 'sul-embed-m3',
            }),
            event.origin
          )
        }
      }
    })
  }
}
