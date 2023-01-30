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
        $('input[type="checkbox"], input[type="text"]', formContainer).on('change', function(){
          const checked   = $(this).is(':checked'),
              inputType = $(this).attr('type'),
              src       = textarea.text().match(/src="(\S+)"/)[1],
              urlAttr   = `&${this.dataset.embedAttr}=true`
          if(inputType === 'checkbox'){
            if(checked) {
              textarea.text(textarea.text().replace(urlAttr, ''));
            }else{
              textarea.text(textarea.text().replace(src, src + urlAttr));
            }
          }else{
            const value = $(this).val()
            if(oldParam = textarea.text().match(`&${this.dataset.embedAttr}=\\w+`)) {
              textarea.text(textarea.text().replace(oldParam, `&${this.dataset.embedAttr}=${value}`));
            }else{
              textarea.text(textarea.text().replace(src, `${src}&${this.dataset.embedAttr}=${value}`));
            }
          }
        });
      }
    };
  })();

  global.EmbedThis = Module;

})( this );
