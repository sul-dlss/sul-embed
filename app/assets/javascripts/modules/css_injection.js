// Module injects css into head of embeded page

(function( global ) {
  var Module = (function() {

    var linkHtml = '<link rel="stylesheet" href="{{stylesheetLink}}" type="text/css" />',
        themeUrl = $("[data-sul-embed-theme]").data("sul-embed-theme"),
        iconsUrl = $('[data-sul-icons]').data('sul-icons'),
        pluginStylesheets = $('[data-plugin-styles]').data('plugin-styles') || '';

    return {
      appendToHead: function() {
        if ( themeUrl ) {
          htmlSnippet = linkHtml.replace("{{stylesheetLink}}", themeUrl);
          $("head").append(htmlSnippet);
        }
      },

      injectFontIcons: function() {
        if ( iconsUrl ) {
          var htmlSnippet = linkHtml.replace('{{stylesheetLink}}', iconsUrl);
          $('head').append(htmlSnippet);
        }
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
