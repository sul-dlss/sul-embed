// Module handles Embed This form interaction

(function( global ) {
  var Module = (function() {
    var formContainer;
    return {
      init: function() {
        var _this = this;
        $(".sul-embed-embed-this-form").each(function(){
          formContainer = $(this);
          _this.observeEmbedForm();
        });
      },
      observeEmbedForm: function() {
        var _this    = this,
            textarea = $('textarea', formContainer);
        $('input[type="checkbox"]', formContainer).on('change', function(){
          var checked  = $(this).is(':checked'),
              src      = textarea.text().match(/src='(\S+)'/)[1],
              url_attr = '&hide_' + $(this).attr('id') + '=true';
          if(checked) {
            textarea.text(textarea.text().replace(url_attr, ''));
          }else{
            textarea.text(textarea.text().replace(src, src + url_attr));
          }
        });
      }
    };
  })();

  global.EmbedThis = Module;

})( this );
