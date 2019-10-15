'use strict';

import fscreen from 'fscreen';

export default {
  fullScreenButton: function() { return $('#full-screen-button'); },

  init: function(fullScreenSelector) {
    $('#full-screen-button').on('click', function() {
      fscreen.requestFullscreen($(fullScreenSelector)[0]);
    });
  }
};
