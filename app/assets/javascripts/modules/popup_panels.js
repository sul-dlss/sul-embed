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
          _this.hideAllOtherPanels();
          _this.toggleAriaAttributes();
          _this.setMaxHeight();
          toggleElements.slideToggle();
        });
      },
      hideAllOtherPanels: function() {
        $("[data-toggle]").each(function(){
          if(clickTarget.data("toggle") != $(this).data('toggle')) {
            $("." + $(this).data("toggle") + ':visible').hide();
          }
        });
      },
      setMaxHeight: function() {
        if (toggleElements.length > 0) {
          var footerHeight = $(".sul-embed-footer").height(),
              totalHeight  = $(".sul-embed-container").height(),
              metaHeight   = toggleElements.height();
          toggleElements.css("maxHeight", totalHeight - footerHeight);
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
