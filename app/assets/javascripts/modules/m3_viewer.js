/* global HandlebarsTemplates */
(function( global ) {
  'use strict';
  var Module = (function() {

    return {
      init: function() {
        var $el = jQuery('#sul-embed-m3');
        var data = $el.data();
        var miradorViewer = Mirador.viewer({
          id: 'sul-embed-m3',
          theme: {
            palette: {
              type: 'dark',
              lightened: {
                dark: '#5f574f'
              }
            }
          },
          windows: [
            {
              loadedManifest: data.m3Uri
            }
          ],
          workspaceControlPanel: {
            enabled: false
          }
        });
      },
    };
  })();

  global.M3Viewer = Module;
})(this);
