'use strict';

import fscreen from 'fscreen';

export default {
  fullScreenButton: function() { return $('#full-screen-button'); },

  init: function(fullScreenSelector) {
    $('#full-screen-button').on('click', function() {
      fscreen.requestFullscreen($(fullScreenSelector)[0]);
    });

    $(fullScreenSelector).on('fullscreenchange', function() {
      var sulEmbedObject = $(fullScreenSelector);

      if (fscreen.fullscreenElement) {
        sulEmbedObject.addClass('sul-embed-fullscreen');
      } else {
        sulEmbedObject.removeClass('sul-embed-fullscreen');
      }
    });
  }
};
