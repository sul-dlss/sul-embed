// Module adds the ability to prevent users from
// clicking through to restricted
(function( global ) {
  'use strict';
  var Module = (function() {
    var linkSelector = '[data-auth-check-url]';

    function addRestrictedLinkClickBehavior() {
      jQuery(linkSelector).on('click', function(e){
        var link = jQuery(this);
        if(link.data('location-cleared') !== 'true') {
          e.preventDefault();
          // This prevents the authentication check from being triggered multiple
          // times since location-cleared will be undefined on the initial state
          // and set to either true or false after the authentication check finishes
          if(link.data('location-cleared') === undefined) {
            var authUrl = link.data('auth-check-url');
            jQuery.ajax({url: authUrl, dataType: 'jsonp'}).done(function(data) {
              // When the auth-check response is successful,
              // add the location-cleared = true flag attribute
              // to the link and re-trigger the click.
              // Otherwise add an error message (with aria
              // attributes) and location-cleared = false flag.
              if(data.status === 'success') {
                link.data('location-cleared', 'true');
                link.trigger('click');
              } else {
                link.data('location-cleared', 'false');
                var errorMessage = jQuery('<span></span>')
                  .addClass('sul-embed-error-message-text')
                  .attr('aria-role', 'region')
                  .attr('aria-live', 'polite')
                  .text('Restricted file cannot be downloaded in your location.');
                link.parent().append(errorMessage);
              }
            });
          }
        }
      });
    }

    return {
      init: function() {
        addRestrictedLinkClickBehavior();
      }
    };
  })();

  global.DownloadLinkAuthCheck = Module;

})( this );
