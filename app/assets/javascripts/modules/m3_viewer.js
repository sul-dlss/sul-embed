'use strict';

import Mirador from 'mirador/dist/es/src/index.js';
import miradorShareDialogPlugin from 'mirador-share-plugin/es/MiradorShareDialog.js';
import miradorSharePlugin from 'mirador-share-plugin/es/miradorSharePlugin.js';
import miradorDownloadPlugin from 'mirador-dl-plugin/es/miradorDownloadPlugin.js';
import miradorDownloadDialogPlugin from 'mirador-dl-plugin/es/MiradorDownloadDialog.js';
import osdReferencePlugin from 'mirador-dl-plugin/es/OSDReferences.js';

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
                /\/iiif\/manifest/,
                '',
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
          windows: [
            {
              defaultSearchQuery: data.search.length > 0 ? data.search : undefined,
              suggestedSearches: data.suggestedSearch.length > 0 ? [data.suggestedSearch] : null,
              loadedManifest: data.m3Uri
            }
          ],
          window: {
            allowClose: false,
            allowFullscreen: true,
            allowMaximize: false,
            authNewWindowCenter: 'screen',
            defaultSideBarPanel: sideBarPanel,
            hideAnnotationsPanel: true,
            hideSearchPanel: false,
            hideWindowTitle: (data.hideTitle === true),
            sideBarOpenByDefault: (data.showAttribution === true || data.search.length > 0)
          },
          workspace: {
            showZoomControls: true,
            type: 'single',
          },
          workspaceControlPanel: {
            enabled: false,
          }
        }, [
          miradorSharePlugin,
          miradorShareDialogPlugin,
          osdReferencePlugin,
          miradorDownloadDialogPlugin,
          miradorDownloadPlugin,
        ]);
      }
    };
