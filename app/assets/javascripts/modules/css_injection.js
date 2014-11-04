// Module injects css into head of embeded page

(function( global ) {
  var Module = (function() {

    var linkHtml = '<link rel="stylesheet" href="{{stylesheetLink}}" type="text/css" />',
        themeUrl = $("[data-sul-embed-theme]").data("sul-embed-theme"),
        pluginStylesheets = $("[data-plugin-styles]").data("plugin-styles") || '',
        fontAwesomeHtml = '<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css" rel="stylesheet">';

    return {
      appendToHead: function() {
        if ( themeUrl ) {
          htmlSnippet = linkHtml.replace("{{stylesheetLink}}", themeUrl);
          $("head").append(htmlSnippet);
        }
      },

      injectFontAwesome: function() {
        $("head").append(fontAwesomeHtml);
      },

      injectPluginStyles: function() {        
        $.each(pluginStylesheets.split(','), function(index, stylesheet) {
          htmlSnippet = linkHtml.replace("{{stylesheetLink}}", stylesheet);
          $("head").append(htmlSnippet);
        });
      }

    };
  })();

  global.CssInjection = Module;

})( this );
