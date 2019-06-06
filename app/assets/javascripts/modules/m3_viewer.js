/* global Mirador */
(function( global ) {
  'use strict';
  var Module = (function() {

    return {
      init: function() {
        var $el = jQuery('#sul-embed-m3');
        var data = $el.data();
        Mirador.viewer({
          id: 'sul-embed-m3',

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
              loadedManifest: data.m3Uri
            }
          ],
          window: {
            allowClose: false,
            allowFullscreen: true,
            allowMaximize: false,
            defaultSideBarPanel: 'attribution',
            hideWindowTitle: (data.hideTitle === true),
            sideBarOpenByDefault: true
          },
          workspaceControlPanel: {
            enabled: false,
            showZoomControls: true
          }
        });
      },
    };
  })();

  global.M3Viewer = Module;
})(this);
