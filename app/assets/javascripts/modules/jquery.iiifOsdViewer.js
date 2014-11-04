(function($) {

  $.fn.iiifOsdViewer = function(options) {

    var iovViews = { },
        config;

    config = $.extend({
      availableViews: ['list', 'gallery', 'horizontal'],
      listView: {
        thumbsWidth: 75
      },
      galleryView: {
        thumbsHeight: 100
      }
    }, options);

    iovViews = {
      list: listView,
      gallery: galleryView,
      horizontal: horizontalView
    };

    return this.each(function() {

      var $parent = $(this),
          $viewer = $('<div>').addClass('iov'),
          $menuBar, $menuControls, $selectViews,
          views = {},
          currentView,
          osd;

      $menuControls = $([
        '<div class="iov-controls">',
          '<a href="javascript:;" class="fa fa-expand iov-full-screen"></a>',
        '</div>',
      ].join(''));

      $selectViews = $('<select class="iov-view-options"></select>');
      $menuBar = $('<div class="iov-menu-bar"></div>');

      $menuBar.append($selectViews).append($menuControls);

      $viewer.height('100%');
      $parent.append($viewer);
      init();

      function init() {
        config.defaultView = config.defaultView || config.availableViews[0];
        config.totalImages = 0;
        currentView = config.defaultView;

        $.each(config.images, function(index, collection) {
          config.totalImages += collection.ids.length || 0;
        });

        addMenuBar();
        attachEvents();
        initializeViews();

        views[currentView].show();
        $selectViews.val(currentView);
      }

      function addMenuBar() {
        $.each(config.availableViews, function(index, view) {
          if (typeof iovViews[view] === 'function') {
            $selectViews.append('<option value="' + view + '">' + view + ' view</option>');
          } else {
            config.availableViews.splice(index, 1);
          }
        });

        $viewer.append($menuBar);
      }

      function initializeViews() {
        $.each(config.availableViews, function(index, view) {
          views[view] = iovViews[view]($viewer, config);

          $viewer.append(views[view].html);
          views[view].hide();
        });
      }

      function jumpTo(view, hashCode) {

      }

      function attachEvents() {
        $menuBar.find('.iov-full-screen').on('click', function() {
          fullscreenElement() ? exitFullscreen() : launchFullscreen($viewer[0]);
        });

        $(document).on('fullscreenchange webkitfullscreenchange mozfullscreenchange msfullscreenChange', function() {
          var $fullscreen = $(fullscreenElement()),
              $ctrlFullScreen = $menuBar.find('.iov-full-screen');

          if ($fullscreen.length && $fullscreen.hasClass('iov')) {
            $ctrlFullScreen.removeClass('fa-expand').addClass('fa-compress');

          } else {
            $ctrlFullScreen.removeClass('fa-compress').addClass('fa-expand');
          }

          if (currentView === 'horizontal') {
            views[currentView].resize();
          }

        });

        $selectViews.on('change', function() {
          currentView = $(this).val();

          hideAllViews();
          views[currentView].show();
        });
      }

      function hideAllViews() {
        $.each(config.availableViews, function(index, view) {
          views[view].hide();
        });
      }

      function launchFullscreen(el) {
        if (el.requestFullscreen) {
          el.requestFullscreen();
        } else if (el.mozRequestFullScreen) {
          el.mozRequestFullScreen();
        } else if (el.webkitRequestFullscreen) {
          el.webkitRequestFullscreen();
        } else if (el.msRequestFullscreen) {
          el.msRequestFullscreen();
        }

      }

      function exitFullscreen() {
        if (document.exitFullscreen) {
          document.exitFullscreen();
        } else if (document.mozCancelFullScreen) {
          document.mozCancelFullScreen();
        } else if (document.webkitExitFullscreen) {
          document.webkitExitFullscreen();
        }
      }

      function fullscreenElement() {
        return (document.fullscreenElement || document.mozFullScreenElement || document.webkitFullscreenElement);
      }

    });

    function hashCode(str) {
      return str.split("").reduce(function(a,b) { a = ((a << 5) - a) + b.charCodeAt(0); return a & a}, 0);
    }

    function getIiifImageUrl(server, id, width, height) {
      width = width || '';
      height = height || '';
      return [server, id, 'full/' + width + ',' + height, '0/native.jpg'].join('/');
    }

    // View modules


    // ------------------------------------------------------------------------
    // Module : List view

    function listView($viewer, config, options) {
      var osd,
          $listView,
          $listViewControls,
          $listViewOsd,
          $thumbsViewport,
          $thumbsList;

      $listViewOsd = $('<div class="iov-list-view-osd" id="iov-list-view-osd"></div>');
      $thumbsViewport = $('<div class="iov-list-view-thumbs-viewport"></div>');
      $thumbsList = $('<ul class="iov-list-view-thumbs"></ul>');

      $listView = $('<div class="iov-list-view"></div>').append($listViewOsd);

      function render() {
        $listViewControls = $([
          '<div class="iov-list-view-controls">',
            '<a href="javascript:;" class="fa fa-plus-circle" id="iov-list-zoom-in"></a>',
            '<a href="javascript:;" class="fa fa-minus-circle" id="iov-list-zoom-out"></a>',
            '<a href="javascript:;" class="fa fa-repeat" id="iov-list-home"></a>',
          '</div>'
        ].join(''));

        // if (config.totalImages > 1) {
          loadListViewThumbs();
        // }

        $viewer.find('.iov-menu-bar').prepend($listViewControls);
      }

      function loadListViewThumbs() {
        $.each(config.images, function(index, collection) {
          $.each(collection.ids, function(index, id) {
            var imgUrl = getIiifImageUrl(collection.iiifServer, id, config.listView.thumbsWidth, null),
                infoUrl = getIiifInfoUrl(collection.iiifServer, id),
                $imgItem = $('<li>');

            $imgItem
              .data('iov-list-view-id', hashCode(id))
              .data('iiif-info-url', infoUrl);

            $thumbsList.append($imgItem.append('<a href="javascript:;"><img src="' + imgUrl + '"></a> '));

            $imgItem.on('click', function() {
              var $self = $(this);

              $self.addClass('iov-list-view-thumb-selected');
              $self.siblings().removeClass('iov-list-view-thumb-selected');
              loadOsdInstance($self);
            });
          });
        });

        $listView.prepend($thumbsViewport.append($thumbsList));
      }

      function loadOsdInstance($imgItem) {
        if (typeof osd !== 'undefined') {
          osd.open($imgItem.data('iiif-info-url'));
        } else {
          osd = OpenSeadragon({
            id: 'iov-list-view-osd',
            tileSources:    $imgItem.data('iiif-info-url'),
            zoomInButton:   'iov-list-zoom-in',
            zoomOutButton:  'iov-list-zoom-out',
            homeButton:     'iov-list-home',
            showFullPageControl: false
          });
        }

      }

      function jumpToImg(hashCode) {
        var $imgItem = $thumbsList.find('[data-iov-list-view-id=="' + hashCode + '"]');

        if ($imgItem.length > 0) {
          loadOsdInstanceg($imgItem);
        }
      }

      function getIiifInfoUrl(server, id) {
        return [server, id, 'info.json'].join('/');
      }

      return {
        html: function() {
          render();
          return $listView;
        },

        hide: function() {
          $listViewControls.hide();
          $listView.hide();
        },

        show: function() {
          $listViewControls.show();
          $listView.show();
          $thumbsList.find('li[data-iov-list-view-id!=""]')[0].click();
        },

        jumpToImg: function(hashCode) {
          jumpToImg(hashCode);
        },

        resize: function() {

        }
      };
    };

    // ------------------------------------------------------------------------
    // Module : Gallery view

    function galleryView($viewer, config, options) {
      var $galleryView,
          $thumbsList;

      $galleryView = $('<div class="iov-gallery-view"></div>');
      $thumbsList = $('<ul class="iov-gallery-view-thumbs"></ul>');

      function render() {
        loadGalleryViewThumbs();
      }

      function loadGalleryViewThumbs() {
        $.each(config.images, function(index, collection) {
          $.each(collection.ids, function(index, id) {
            var imgUrl = getIiifImageUrl(collection.iiifServer, id, null, config.galleryView.thumbsHeight),
                $imgItem = $('<li>');

            $imgItem.data('iov-gallery-view-id', hashCode(id));
            $thumbsList.append($imgItem.append('<img src="' + imgUrl + '">'));

            // if ($.inArray('list', config.availableViews) !== -1) {
            //   $imgItem.on('click', function() {
            //     jumpTo('list', $(this).data('iov-gallery-view-id'));
            //   });
            // }
          });
        });

        $galleryView.prepend($thumbsList);
      }

      return {
        html: function() {
          render();
          return $galleryView;
        },

        hide: function() {
          $galleryView.hide();
        },

        show: function() {
          $galleryView.show();
        },

        resize: function() {

        }

      };
    }

    // ------------------------------------------------------------------------
    // Module : Scroll view

    function horizontalView($viewer, config, options) {
      var $horizontalView,
          $imgsList;

      $horizontalView = $('<div class="iov-horizontal-view"></div>');
      $viewport = $('<div class="iov-horizontal-view-viewport"></div>');
      $imgsList = $('<ul class="iov-horizontal-view-images"></ul>');

      function render() {
        loadHorizontalImageStubs();
      }

      function loadHorizontalImageStubs() {
        $.each(config.images, function(index, collection) {
          $.each(collection.ids, function(index, id) {
            var $imgItem = $('<li>');

            $imgItem
              .data('iov-horizontal-view-id', hashCode(id))
              .data('iov-iiif-server', collection.iiifServer)
              .data('iov-iiif-image-id', id);

            $imgsList.append($imgItem.append('<img src="">'));
          });
        });

        $horizontalView.append($viewport.append($imgsList));
      }

      function loadHorizontalViewImages() {
        var height0,
            imgsList = $imgsList.find('li[data-horizontal-view-id!=""]');

        $viewport.detach();

        height = $horizontalView.innerHeight() - 20,

        $.each(imgsList, function(index, imgItem) {
          var $imgItem = $(imgItem),
              iiifServer = $imgItem.data('iov-iiif-server'),
              id = $imgItem.data('iov-iiif-image-id'),
              imgUrl = getIiifImageUrl(iiifServer, id, null, height);

          $imgItem.find('img').attr('src', imgUrl);
        });

        $horizontalView.append($viewport);
      }

      return {
        html: function() {
          render();
          return $horizontalView;
        },

        hide: function() {
          $horizontalView.hide();
        },

        show: function() {
          $horizontalView.show();
          loadHorizontalViewImages();
        },

        resize: function() {
          loadHorizontalViewImages();
        }
      };
    }


  };




})( jQuery );
