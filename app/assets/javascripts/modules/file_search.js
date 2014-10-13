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
        this.showSearchInput();
        mediaObjectList = new List("sul-embed-object", options);
        return mediaObjectList;
      },
      showSearchInput: function() {
        $(".sul-embed-search").removeClass("sul-embed-hidden");
      }
    };
  })();

  global.FileSearch = Module;

})( this );
