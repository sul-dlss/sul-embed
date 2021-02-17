// Module handles common viewer behaviors

(function( global ) {
  var Module = (function() {
    var viewerShown = $.Deferred();

    return {
      initializeViewer: function(callback) {
        var _this = this;
        this.showViewer();
        $.when(viewerShown).done(function() {
          _this.initializeTooltip();
          if (typeof callback !== 'undefined') {
            callback();
          }
        });
      },
      initializeTooltip: function() {
        $("[data-sul-embed-tooltip='true']").each(function() {
          $(this).tooltip();
        });
      },
      showViewer: function() {
        $("#sul-embed-object").show(function() {
          viewerShown.resolve();
        });
      }
    };
  })();

  // Basic support of CommonJS module for import into test
  if (typeof exports === "object") {
    module.exports = Module;
  }

  global.CommonViewerBehavior = Module;

})( this || {} );
