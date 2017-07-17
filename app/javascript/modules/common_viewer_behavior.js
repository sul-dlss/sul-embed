// Class handles common viewer behaviors

export default class CommonViewerBehavior {
  constructor() {
    this.viewerShown = $.Deferred();
  }

  initializeViewer (callback) {
    const _this = this;
    _this.showViewer();
    $.when(_this.viewerShown).done(function() {
      _this.initializeTooltip();
      if (typeof callback !== 'undefined') {
        callback();
      }
    });
  }

  initializeTooltip() {
    $("[data-sul-embed-tooltip='true']").each(function() {
      $(this).tooltip();
    });
  }

  showViewer() {
    const _this = this;
    $("#sul-embed-object").show(function() {
      _this.viewerShown.resolve();
    });
  }
};
