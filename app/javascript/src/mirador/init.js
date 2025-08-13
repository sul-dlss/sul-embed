import Mirador from 'mirador';
import { miradorImageToolsPlugin } from 'mirador-image-tools';
import { miradorSharePlugin, miradorShareDialogPlugin } from 'mirador-share-plugin';
import { miradorDownloadPlugin, miradorDownloadDialogPlugin } from 'mirador-dl-plugin';

import { sulTheme, viewerViews, defaultWorkspace } from '@/mirador/config.js';
import { handleViewerPostMessage } from '@/mirador/postMessageHandler.js';

import embedModePlugin from '@/mirador/plugins/embedModePlugin.js';
import analyticsPlugin from '@/mirador/plugins/analyticsPlugin.js';
import xywhPlugin from '@/mirador/plugins/xywhPlugin.js';
import customMenuPlugin from '@/mirador/plugins/customMenuPlugin.jsx';

export default {

  init: function () {
    const el = document.getElementById('sul-embed-m3');
    const data = el.dataset;

    const showAttribution = data.showAttribution === 'true';
    const hideWindowTitle = data.hideTitle === 'true';
    const enableComparison = data.enableComparison === 'true';

    // Determine which sidebar panel to show
    let sideBarPanel = 'info';
    if (data.search?.length > 0) sideBarPanel = 'search';
    if (showAttribution) sideBarPanel = 'attribution';

    const viewerInstance = Mirador.viewer({
      id: 'sul-embed-m3',
      selectedTheme: 'sul',
      themes: sulTheme,
      windows: [
        {
          id: 'main',
          loadedManifest: data.m3Uri,
          canvasIndex: Number(data.canvasIndex),
          canvasId: data.canvasId,
          defaultSearchQuery: data.search?.length > 0 ? data.search : undefined,
          suggestedSearches: data.suggestedSearch?.length > 0 ? [data.suggestedSearch] : null,
          ...(data.viewerConfig && { initialViewerConfig: JSON.parse(data.viewerConfig) }),
        },
      ],
      window: {
        allowClose: false,
        allowFullscreen: true,
        allowMaximize: false,
        authNewWindowCenter: 'screen',
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
      miradorDownloadPlugin: {
        restrictDownloadOnSizeDefinition: true,
      },
    },
    [
      ...(enableComparison ? embedModePlugin : []),
      analyticsPlugin,
      xywhPlugin,
      customMenuPlugin,
      ...miradorImageToolsPlugin,
      { ...miradorSharePlugin, target: 'CustomMenuComponent' },
      miradorShareDialogPlugin,
      { ...miradorDownloadPlugin, target: 'CustomMenuComponent' },
      miradorDownloadDialogPlugin,
    ]);

    handleViewerPostMessage(viewerInstance);
  }
};