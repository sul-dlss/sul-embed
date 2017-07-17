// Class adds popup panel behavior

export default class PopupPanels {
  constructor() {
    this.clickTarget = null;
    this.toggleElements = null;
  }
  init() {
    this.setupListeners();
  }
  setupListeners() {
    const _this = this;
    $("[data-sul-embed-toggle]").on("click", function() {
      _this.clickTarget = $(this);
      _this.toggleElements = $("." + _this.clickTarget.data("sul-embed-toggle"));
      _this.hideAllOtherPanels();
      _this.toggleAriaAttributes();
      _this.setMaxHeight();
      _this.toggleElements.slideToggle();
    });
  }
  hideAllOtherPanels() {
    const _this = this;
    $("[data-sul-embed-toggle]").each(function(){
      if(_this.clickTarget.data("sul-embed-toggle") != $(this).data('sul-embed-toggle')) {
        $("." + $(this).data("sul-embed-toggle") + ':visible').hide();
      }
    });
  }
  setMaxHeight() {
    if (this.toggleElements.length > 0) {
      var footerHeight = $(".sul-embed-footer").height(),
          totalHeight  = $(".sul-embed-container").height(),
          metaHeight   = this.toggleElements.height();
      this.toggleElements.css("maxHeight", totalHeight - footerHeight);
    }
  }
  toggleAriaAttributes() {
    if(this.toggleElements.is(':visible')) {
      this.clickTarget.attr('aria-expanded', 'false');
      this.toggleElements.attr('aria-hidden', 'true');
    }else{
      this.clickTarget.attr('aria-expanded', 'true');
      this.toggleElements.attr('aria-hidden', 'false');
    }
  }
}
