// Module handles common viewer behaviors

(function( global ) {
  var Module = (function() {

    return {
      showViewer: function() {
        $("#sul-embed-object").show();
      }
    };
  })();

  global.CommonViewerBehavior = Module;

})( this );
