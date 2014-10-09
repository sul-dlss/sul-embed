(function( $ ) {

  $.fn.embedOsdViewer = function() {

    return this.each(function() {
      var $viewer = $( this ),
          id = $viewer.attr( 'id' ),
          iiifInfoUrl = $viewer.data( 'iiif-info-url' ),
          osd;

      init();

      function init() {
        if ( typeof OpenSeadragon === 'function' ) {
          if ( typeof osd !== 'undefined' ) {
            osd.destroy();
          }

          osd = OpenSeadragon({
            id: id,
            tileSources:    iiifInfoUrl,
            zoomInButton:   id + '-zoom-in',
            zoomOutButton:  id + '-zoom-out',
            homeButton:     id + '-home',
            fullPageButton: id + '-full-page'
          });
        }
      }

    });

  }

})( jQuery );
