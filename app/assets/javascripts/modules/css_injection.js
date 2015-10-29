// Module injects css into head of embeded page

(function( global ) {
  var Module = (function() {

    var linkHtml = '<link rel="stylesheet" href="{{stylesheetLink}}" type="text/css" />',
        themeUrl = $("[data-sul-embed-theme]").data("sul-embed-theme"),
        pluginStylesheets = $("[data-plugin-styles]").data("plugin-styles") || '',
        fontIconsHtml = '<link href="https://sul-cdn.stanford.edu/sul_s' +
          'tyles/0.5.1/sul-icons.min.css" rel="stylesheet">';

    return {
      appendToHead: function() {
        if ( themeUrl ) {
          htmlSnippet = linkHtml.replace("{{stylesheetLink}}", themeUrl);
          $("head").append(htmlSnippet);
        }
      },

      injectFontIcons: function() {
        $('head').append(fontIconsHtml);
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
