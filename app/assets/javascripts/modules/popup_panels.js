// Module adds popup panel behavior

(function( global ) {
  var Module = (function() {
    var clickTarget;
    var toggleElements;
    return {
      init: function() {
        this.setupListeners();
      },
      setupListeners: function() {
        var _this = this;
        $("[data-toggle]").on("click", function() {
          clickTarget = $(this);
          toggleElements = $("." + clickTarget.data("toggle"));
          _this.setHeights();
          _this.toggleAriaAttributes();
          toggleElements.slideToggle();
        });
      },
      setHeights: function() {
        if (toggleElements.length > 0) {
          var footerHeight = $(".sul-embed-footer").height(),
            totalHeight = $(".sul-embed-container").height(),
            metaHeight = toggleElements.height();
          if (metaHeight < totalHeight){
            toggleElements.height(totalHeight - footerHeight);
          }else {
            toggleElements.css("maxHeight", totalHeight - footerHeight);
          }
        }
      },
      toggleAriaAttributes: function() {
        if(toggleElements.is(':visible')) {
          clickTarget.attr('aria-expanded', 'false');
          toggleElements.attr('aria-hidden', 'true');
        }else{
          clickTarget.attr('aria-expanded', 'true');
          toggleElements.attr('aria-hidden', 'false');
        }
      }
    };
  })();

  global.PopupPanels = Module;

})( this );
