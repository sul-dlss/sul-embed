// Module injects css into head of embeded page

(function( global ) {
  const Module = (function() {

    const linkHtml = '<link rel="stylesheet" href="{{stylesheetLink}}" type="text/css" />',
        themeUrl = document.querySelector("[data-sul-embed-theme]").dataset.sulEmbedTheme,
        iconsNode = document.querySelector('[data-sul-icons]'),
        pluginStylesheets = document.querySelector('[data-plugin-styles]')?.dataset?.pluginStyles || '';

    return {
      appendToHead: function() {
        if ( themeUrl ) {
          htmlSnippet = linkHtml.replace("{{stylesheetLink}}", themeUrl);
          $("head").append(htmlSnippet);
        }
      },

      injectFontIcons: function() {
        if ( iconsNode ) {
          const iconsUrl = iconsNode.dataset.sulIcons
          const htmlSnippet = linkHtml.replace('{{stylesheetLink}}', iconsUrl);
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
