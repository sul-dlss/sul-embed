// Module injects css into head of embeded page

(function( global ) {
  var Module = (function() {

    var linkHtml = '<link rel="stylesheet" href="{{stylesheetLink}}" type="text/css" />',
      themeUrl = $("[data-sul-embed-theme]").data("sul-embed-theme");
    return {
      appendToHead: function() {
        if ( themeUrl ) {
          htmlSnippet = linkHtml.replace("{{stylesheetLink}}", themeUrl);
          $("head").append(htmlSnippet);
        }
      }
    };
  })();

  global.CssInjection = Module;

})( this );
