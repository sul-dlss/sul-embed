// Module handles common viewer behaviors

(function( global ) {
  var Module = (function() {
    var viewerShown = $.Deferred(),
        purlLinkWidthCutoff = 400;

    function updatePurlLink(width) {
      var $purlLink = $('.sul-embed-purl-link a');

      if (width < purlLinkWidthCutoff) {
        $purlLink.text($purlLink.text().replace('purl.stanford.edu/', ''));
      }
    }

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
          updatePurlLink($("#sul-embed-object").outerWidth());
        });
      }
    };
  })();

  global.CommonViewerBehavior = Module;

})( this );
