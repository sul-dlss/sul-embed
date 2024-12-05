// Module handles Embed This form interaction

const EmbedThis = (function() {
  let formContainer
  return {
    init: function() {
      const _this = this
      $(".sul-embed-embed-this-form").each(function(){
        formContainer = $(this)
        _this.observeEmbedForm()
      })
    },
    observeEmbedForm: function() {
      const _this    = this,
          textarea = $('textarea', formContainer)
      $('input[type="checkbox"], input[type="text"]', formContainer).on('change', function(){
        const checked   = $(this).is(':checked'),
            inputType = $(this).attr('type'),
            src       = textarea.text().match(/src="(\S+)"/)[1],
            urlAttr   = '&' + $(this).data('embed-attr') + '=true'
        if(inputType === 'checkbox'){
          if(checked) {
            textarea.text(textarea.text().replace(urlAttr, ''))
          }else{
            textarea.text(textarea.text().replace(src, src + urlAttr))
          }
        }else{
          if(oldParam = textarea.text().match('&' + $(this).data('embed-attr') + "=\\w+")) {
            textarea.text(textarea.text().replace(oldParam, '&' + $(this).data('embed-attr') + '=' + $(this).val()))
          }else{
            textarea.text(textarea.text().replace(src, src + '&' + $(this).data('embed-attr') + '=' + $(this).val()))
          }
        }
      })
    }
  }
})()

export default EmbedThis