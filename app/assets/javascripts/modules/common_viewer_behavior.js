// Module handles common viewer behaviors

import $ from "jquery";

const viewerShown = $.Deferred();

export const initializeViewer = function (callback) {
  showViewer();
  $.when(viewerShown).done(function () {
    if (typeof callback === "function") {
      callback();
    }
  });
};

const showViewer = function () {
  $("#sul-embed-object").show(function () {
    viewerShown.resolve();
  });
};
