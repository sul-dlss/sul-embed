// Module initializes file search functionality

(function( global ) {
  var Module = (function() {

    var mediaObjectList,
      options = {
        listClass: "sul-embed-media-list",
        searchClass: "sul-embed-search-input",
        valueNames: [ "sul-embed-media-heading", "sul-embed-description" ]
      };

    return {
      init: function() {
        mediaObjectList = new List("sul-embed-object", options);
        return mediaObjectList;
      }
    };
  })();

  global.FileSearch = Module;

})( this );
