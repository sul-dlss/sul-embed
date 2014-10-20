// Module handles common viewer behaviors

(function( global ) {
  var Module = (function() {
    var viewerShown = $.Deferred();

    return {
      initializeViewer: function() {
        var _this = this;
        this.showViewer();
        $.when(viewerShown).done(function() {
          _this.initializeTooltip();
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

  global.CommonViewerBehavior = Module;

})( this );
