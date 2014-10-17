// Module initializes file search functionality

(function( global ) {
  var Module = (function() {

    var mediaObjectList,
      itemCount = $("<div class='sul-embed-item-count'></div>"),
      options = {
        listClass: "sul-embed-media-list",
        page: 99999,
        searchClass: "sul-embed-search-input",
        valueNames: [ "sul-embed-media-heading", "sul-embed-description" ]
      };

    $(".sul-embed-footer").append(itemCount);

    return {
      init: function() {
        mediaObjectList = new List("sul-embed-object", options);
        this.updateCount();
        this.listenForUpdate();
        return mediaObjectList;
      },
      listenForUpdate: function() {
        var _this = this;
        mediaObjectList.on("updated", function(e) {
          _this.updateCount();
        });
      },
      updateCount: function() {
        var count = mediaObjectList.visibleItems.length,
          itemText = count === 1 ? " item" : " items";
        itemCount.html(count + itemText);
      }
    };
  })();

  global.FileSearch = Module;

})( this );
