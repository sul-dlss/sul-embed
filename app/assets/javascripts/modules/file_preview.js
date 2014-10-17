// Module adds behavior to Preview/Close preview for file objects

(function( global ) {
  var Module = (function() {

    return {
      init: function() {
        $('.sul-embed-container').each(function(){
          FilePreview.addPreviewToggleBehavior($(this));
        });
      },
      addPreviewToggleBehavior: function(container) {
        $('[data-sul-embed-file-preview-toggle="true"]', container).each(function(){
          $('a', $(this)).click(function(e){ e.preventDefault(); });
          $(this).click(function(){
            FilePreview.togglePreviewIcon($(this));
            FilePreview.togglePreviewText($(this));
            FilePreview.togglePreviewWindow($(this));
          });
        });
      },
      togglePreviewIcon: function(preview) {
        var icon = $('.fa', preview);
        if(icon.hasClass('fa-toggle-right')) {
          icon.removeClass('fa-toggle-right');
          icon.addClass('fa-toggle-down');
        }else{
          icon.removeClass('fa-toggle-down');
          icon.addClass('fa-toggle-right');
        }
      },
      togglePreviewText: function(preview) {
        var text = $('[data-sul-embed-file-preview-toggle-text="true"]', preview);
        if(text.text() == "Preview") {
          text.text("Close preview")
        }else{
          text.text("Preview")
        }
      },
      togglePreviewWindow: function(preview) {
        var previewWindow = preview.closest('li').find('[data-sul-embed-file-preview-window="true"]');
        var icon = $('.fa', preview);
        if(icon.hasClass('fa-toggle-down')) {
          previewWindow.slideDown();
        }else{
          previewWindow.slideUp();
        }
      }
    };
  })();

  global.FilePreview = Module;

})( this );
