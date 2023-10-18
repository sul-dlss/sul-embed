import fscreen from "fscreen";
import $ from "jquery";

export default {
  closeFullScreenButton: function () {
    return $("#close-full-screen-button");
  },
  fullScreenButton: function () {
    return $("#full-screen-button");
  },

  init: function (fullScreenSelector) {
    this.fullScreenButton().on("click", function () {
      fscreen.requestFullscreen($(fullScreenSelector)[0]);
    });

    this.closeFullScreenButton().on("click", function () {
      fscreen.exitFullscreen();
    });
  },
};
