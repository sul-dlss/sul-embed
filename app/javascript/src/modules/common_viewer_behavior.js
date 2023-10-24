// Module handles common viewer behaviors

(function( global ) {
  var Module = (function() {
    var viewerShown = $.Deferred();

    return {
      initializeViewer: function(callback) {
        this.showViewer();
        $.when(viewerShown).done(function() {
          if (typeof callback !== 'undefined') {
            callback();
          }
        });
      },
      showViewer: function() {
        $("#sul-embed-object").show(function() {
          viewerShown.resolve();
        });
      }
    };
  })();

  // Basic support of CommonJS module for import into test
  if (typeof exports === "object") {
    module.exports = Module;
  }

  global.CommonViewerBehavior = Module;

})( this || {} );
