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
        var icon = $('i', preview);
        if(icon.hasClass('sul-i-arrow-right-8')) {
          icon.removeClass('sul-i-arrow-right-8');
          icon.addClass('sul-i-arrow-down-8');
        }else{
          icon.removeClass('sul-i-arrow-down-8');
          icon.addClass('sul-i-arrow-right-8');
        }
      },
      togglePreviewText: function(preview) {
        var content = $('[data-sul-embed-file-preview-toggle-text="true"]', preview),
          text = content.text(),
          srText = text.substring(text.indexOf("item"), text.length);
        if (text.indexOf("Preview") > -1) {
          content.html("Close preview <span class='sul-embed-sr-only'> " + srText + "</span>");
          content.attr("aria-expanded", true);
        }else {
          content.html("Preview <span class='sul-embed-sr-only'> " + srText + "</span>");
          content.attr("aria-expanded", false);
        }
      },
      togglePreviewWindow: function(preview) {
        var previewWindow = preview.closest('li').find('[data-sul-embed-file-preview-window="true"]');
        var icon = $('i', preview);
        if(icon.hasClass('sul-i-arrow-down-8')) {
          previewWindow.slideDown();
          previewWindow.attr("aria-hidden", false);
        }else {
          previewWindow.slideUp();
          previewWindow.attr("aria-hidden", true);
        }
      }
    };
  })();

  global.FilePreview = Module;

})( this );
