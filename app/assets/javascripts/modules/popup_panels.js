// Module adds popup panel behavior

(function( global ) {
  var Module = (function() {
    var toggleElements;
    return {
      init: function() {
        this.setupListeners();
      },
      setupListeners: function() {
        var _this = this;
        $("[data-toggle]").on("click", function() {
          toggleElements = $("." + $(this).data("toggle"));
          _this.setHeights();
          _this.setWidth();
          toggleElements.slideToggle();
        });
      },
      setHeights: function() {
        if (toggleElements.length > 0) {
          var footerHeight = $(".sul-embed-footer").height(),
            totalHeight = $(".sul-embed-container").height(),
            metaHeight = toggleElements.height();
          if (metaHeight < totalHeight){
            toggleElements.height(totalHeight - footerHeight - 10);
          }else {
            toggleElements.css("maxHeight", totalHeight - footerHeight + 10);
          }
        }
      },
      setWidth: function() {
        if (toggleElements.length > 0) {
          var containerWidth = toggleElements.closest('#sul-embed-object').outerWidth();
          toggleElements.outerWidth(containerWidth - 2);
        }
      }
    };
  })();

  global.PopupPanels = Module;

})( this );
