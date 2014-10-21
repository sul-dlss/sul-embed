// Module injects css into head of embeded page

(function( global ) {
  var Module = (function() {

    return {
      init: function() {
        this.setupListeners();
      },
      setupListeners: function() {
        var _this = this;
        $("[data-toggle]").on("click", function() {
          _this.setHeights();
          var toggleElements = $("." + $(this).data("toggle"));
          toggleElements.slideToggle();
        });
      },
      setHeights: function() {
        var footerHeight = $(".sul-embed-footer").height(),
          totalHeight = $(".sul-embed-container").height(),
          metaHeight = $(".sul-embed-metadata-panel").height();

        if (metaHeight < totalHeight){
          $(".sul-embed-metadata-panel").height(totalHeight - footerHeight - 10);
        }else {
          $(".sul-embed-metadata-panel").css("maxHeight", totalHeight - footerHeight + 10);
        }
      }
    };
  })();

  global.MetadataPanel = Module;

})( this );
