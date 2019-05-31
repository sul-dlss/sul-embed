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
          
          selectedTheme: 'stanford',
          themes: {
            stanford: {
              palette: {
                type: 'dark',
                primary: {
                  main: '#610e0e',
                },
                secondary: {
                  main: '#610e0e',
                },
                shades: {
                  dark: '#000000',
                  main: '#5f574f',
                  light: '#616161',
                }
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
            allowMaximize: false,
            hideAnnotationsPanel: true,
            sideBarOpenByDefault: true
          },
          workspaceControlPanel: {
            enabled: false
          }
        });
      },
    };
  })();

  global.M3Viewer = Module;
})(this);
