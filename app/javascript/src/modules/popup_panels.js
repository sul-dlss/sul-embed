// Module adds popup panel behavior

const PopupPanels = (function() {
    let clickTarget, toggleElements
    return {
      init: function() {
        this.setupListeners()
      },
      setupListeners: function() {
        const _this = this
        $("[data-sul-embed-toggle]").on("click", function() {
          clickTarget = $(this)
          toggleElements = $("." + clickTarget.data("sul-embed-toggle"))
          _this.hideAllOtherPanels()
          _this.toggleAriaAttributes()
          _this.setMaxHeight()
          toggleElements.slideToggle()
        })
      },
      hideAllOtherPanels: function() {
        $("[data-sul-embed-toggle]").each(function(){
          if(clickTarget.data("sul-embed-toggle") != $(this).data('sul-embed-toggle')) {
            $("." + $(this).data("sul-embed-toggle") + ':visible').hide()
          }
        })
      },
      setMaxHeight: function() {
        if (toggleElements.length > 0) {
          var footerHeight = $(".sul-embed-footer").height(),
              totalHeight  = $(".sul-embed-container").height(),
              metaHeight   = toggleElements.height()
          toggleElements.css("maxHeight", totalHeight - footerHeight)
        }
      },
      toggleAriaAttributes: function() {
        if(toggleElements.is(':visible')) {
          clickTarget.attr('aria-expanded', 'false')
          toggleElements.attr('aria-hidden', 'true')
        }else{
          clickTarget.attr('aria-expanded', 'true')
          toggleElements.attr('aria-hidden', 'false')
        }
      }
    }
})()

export default PopupPanels
