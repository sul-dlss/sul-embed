// Class initializes file search functionality
import List from 'list.js'

export default class FileSearch {
  constructor() {
    this.mediaObjectList = null;
    this.itemCount = $(".sul-embed-item-count");
    this.options = {
        listClass: "sul-embed-media-list",
        page: 99999,
        searchClass: "sul-embed-search-input",
        valueNames: [ "sul-embed-media-heading", "sul-embed-description" ]
    };
  }

  init() {
    this.mediaObjectList = new List("sul-embed-object", this.options);
    this.updateCount();
    this.listenForUpdate();
  }

  listenForUpdate() {
    const _this = this;
    this.mediaObjectList.on("updated", function(e) {
      _this.updateCount();
    });
  }

  updateCount() {
    const count = this.mediaObjectList.visibleItems.length;
    const itemText = count === 1 ? " item" : " items";
    
    this.itemCount.html(count + itemText);
  }
}
