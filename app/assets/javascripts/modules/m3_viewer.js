'use strict';

import Mirador from 'mirador/dist/es/src/index.js';
import miradorImageToolsPlugin from 'mirador-image-tools/es/plugins/miradorImageToolsPlugin.js';
import miradorShareDialogPlugin from 'mirador-share-plugin/es/MiradorShareDialog.js';
import miradorSharePlugin from 'mirador-share-plugin/es/miradorSharePlugin.js';
import miradorDownloadPlugin from 'mirador-dl-plugin/es/miradorDownloadPlugin.js';
import miradorDownloadDialogPlugin from 'mirador-dl-plugin/es/MiradorDownloadDialog.js';
import shareMenuPlugin from '../plugins/shareMenuPlugin';
import miradorZoomBugPlugin from '../plugins/miradorZoomBugPlugin';
import embedModePlugin from '../plugins/embedModePlugin';
import analyticsPlugin from '../plugins/analyticsPlugin';
import cdlAuthPlugin from '../plugins/cdlAuthPlugin';
import three3DPlugin from '../plugins/threeDPlugin';

export default {
  init: function() {
    var $el = jQuery('#sul-embed-m3');
    var data = $el.data();

    // Determine which panel should be open
    var sideBarPanel = 'info';
    if (data.search) {
      sideBarPanel = 'search';
    }
    if (data.showAttribution) {
      sideBarPanel = 'attribution';
    }

    Mirador.viewer({
      id: 'sul-embed-m3',
      miradorDownloadPlugin: {
        restrictDownloadOnSizeDefinition: true,
      },
      miradorSharePlugin: {
        embedOption: {
          enabled: true,
          embedUrlReplacePattern: [
            /.*\.edu\/(\w+)\/iiif\/manifest/,
            'https://embed.stanford.edu/iframe?url=https://purl.stanford.edu/$1',
          ],
        },
        dragAndDropInfoLink: 'https://library.stanford.edu/projects/international-image-interoperability-framework/viewers',
        shareLink: {
          enabled: true,
          manifestIdReplacePattern: [
            /(purl.*.stanford.edu.*)\/iiif\/manifest(.json)?$/,
            '$1',
          ],
        },
      },
      // // ...(data.threeD && {
      //   requests: {
      //     preprocessors: [
      //       (url, options) => {
      //         console.log(options);
      //         return {...options, headers: { ...options.headers, Accept: 'application/ld+json;profile="http://iiif.io/api/presentation/3/context.json", */*'}}
      //       }
      //     ]
      //   },
      // // }),
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
        loadedManifest: (data.threeD ? data.m3Uri.replace('/iiif/', '/iiif3/') : data.m3Uri),
        canvasIndex: Number(data.canvasIndex),
        canvasId: data.canvasId,
        ...(data.cdl && {
          cdl: {
            cdlHoldRecordId: data.cdlHoldRecordId && data.cdlHoldRecordId.toString(),
          }
        }),
      }],
      window: {
        allowClose: false,
        allowFullscreen: true,
        allowMaximize: false,
        authNewWindowCenter: 'screen',
        sideBarPanel,
        hideWindowTitle: (data.hideTitle === true),
        panels: {
          annotations: true,
          layers: true,
          search: true,
        },
        sideBarOpen: (data.showAttribution === true || data.search.length > 0),
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
        type: data.imageTools ? 'mosaic' : 'single',
      },
      workspaceControlPanel: {
        enabled: false,
      }
    }, [
      ...((data.cdl && cdlAuthPlugin) || []),
      ...((data.imageTools && miradorImageToolsPlugin) || []),
      (!data.cdl && shareMenuPlugin),
      miradorZoomBugPlugin,
      ...((data.imageTools && embedModePlugin) || []),
      {
        ...miradorSharePlugin,
        target: 'WindowTopBarShareMenu',
      },
      miradorShareDialogPlugin,
      miradorDownloadDialogPlugin,
      {
        ...miradorDownloadPlugin,
        target: 'WindowTopBarShareMenu',
      },
      three3DPlugin,
      analyticsPlugin,
    ].filter(Boolean));
  }
};
