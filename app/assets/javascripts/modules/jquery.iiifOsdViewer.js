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
          osd;

      $menuControls = $([
        '<div class="iov-controls">',
          '<a href="javascript:;" class="fa fa-expand iov-full-screen"></a>',
        '</div>',
      ].join(''));

      $selectViews = $('<select class="iov-view-options"></select>');
      $menuBar = $('<div class="iov-menu-bar"></div>');

      $viewer.height('100%');
      $parent.append($viewer);
      init();


      function init() {
        config.defaultView = config.defaultView || config.availableViews[0];
        config.totalImages = 0;
        config.currentView = config.defaultView;

        $.each(config.data, function(index, collection) {
          config.totalImages += collection.images.length || 0;
        });

        $.subscribe('iov-jump-to-list-view', jumpTo('list'));
        $.subscribe('iov-list-view-load', updateDownloadPanel());
        $.subscribe('iov-gallery-view-load', disableDownload());
        $.subscribe('iov-horizontal-view-load', disableDownload());

        addMenuBar();
        attachEvents();
        initializeViews();
        views[config.currentView].load();
        $selectViews.val(config.currentView);
      }

      function addMenuBar() {
        if (config.totalImages > 1) {
          $menuBar.append($selectViews);

          $.each(config.availableViews, function(index, view) {
            if (typeof iovViews[view] === 'function') {
              $selectViews.append('<option value="' + view + '">' + view + ' view</option>');
            } else {
              config.availableViews.splice(index, 1);
            }
          });
        } else {
          config.availableViews = ['list'];
        }

        $menuBar.append($menuControls);
        $viewer.append($menuBar);
      }

      function initializeViews() {
        $.each(config.availableViews, function(index, view) {
          views[view] = iovViews[view]($viewer, config);

          $viewer.append(views[view].html());
          views[view].hide();
        });
      }

      function jumpTo(view) {
        return function(_, hashCode) {
          hideAllViews();

          views[view].show();
          views[view].jumpToImg(hashCode);
          $selectViews.val(view);
          config.currentView = view;
        }
      }

      function updateDownloadPanel() {
        return function(_, hashCode) {
          var $imgItem = $('.iov-list-view-id-' + hashCode);

          if ($imgItem.length) {
            sulEmbedDownloadPanel.update($imgItem.data());
          }
        }
      }

      function disableDownload() {
        return function(_) {
          sulEmbedDownloadPanel.disableDownload();
        }
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

          if (config.currentView === 'horizontal') {
            views[config.currentView].resize();
          }
        });

        $selectViews.on('change', function() {
          config.currentView = $(this).val();

          hideAllViews();
          views[config.currentView].load();
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

      $listView = $('<div class="iov-list-view"></div>');

      function render() {
        $listViewControls = $([
          '<div class="iov-list-view-controls">',
            '<a href="javascript:;" class="fa fa-plus-circle" id="iov-list-zoom-in"></a>',
            '<a href="javascript:;" class="fa fa-minus-circle" id="iov-list-zoom-out"></a>',
            '<a href="javascript:;" class="fa fa-repeat" id="iov-list-home"></a>',
          '</div>'
        ].join(''));

        $listView.append($listViewOsd);
        $viewer.find('.iov-menu-bar').prepend($listViewControls);

        loadListViewThumbs();
      }

      function loadListViewThumbs() {
        $.each(config.data, function(index, collection) {
          $.each(collection.images, function(index, image) {
            var imgUrl = getIiifImageUrl(collection.iiifServer, image.id, config.listView.thumbsWidth, null),
                infoUrl = getIiifInfoUrl(collection.iiifServer, image.id),
                $imgItem = $('<li data-alt="' + image.label + '">');

            $imgItem
              .addClass('iov-list-view-id-' + hashCode(image.id))
              .data({
                'iov-list-view-id': hashCode(image.id),
                'image-id': image.id,
                'iov-height': image.height,
                'iov-width': image.width,
                'iov-stanford-only': image.stanford_only,
                'iov-tooltip-text': image.tooltip_text,
                'iiif-info-url': infoUrl
              });

            $thumbsList.append($imgItem.append('<a href="javascript:;"><img alt="' + image.label + '" src="' + imgUrl + '"></a> '));

            $imgItem.on('click', function() {
              var $self = $(this);

              $self.addClass('iov-list-view-thumb-selected');
              $self.siblings().removeClass('iov-list-view-thumb-selected');
              updateView($self);

              $.publish('iov-list-view-load', $imgItem.data('iov-list-view-id'));
            });
          });
        });

        $listView.prepend($thumbsViewport.append($thumbsList));

        if (config.totalImages == 1) {
          $listViewOsd.addClass('iov-remove-margin');
          $thumbsViewport.hide();
        }
      }

      function updateView($imgItem) {
        loadOsdInstance($imgItem.data('iiif-info-url'));
        scrollThumbsViewport($imgItem);
      }

      function loadOsdInstance(infoUrl) {
        if (typeof osd !== 'undefined') {
          osd.open(infoUrl);
        } else {
          osd = OpenSeadragon({
            id:             'iov-list-view-osd',
            tileSources:    infoUrl,
            zoomInButton:   'iov-list-zoom-in',
            zoomOutButton:  'iov-list-zoom-out',
            homeButton:     'iov-list-home',
            showFullPageControl: false
          });
        }
      }

      function scrollThumbsViewport($imgItem) {
        var scrollTo = 0,
            top = $imgItem.position().top;

        if (typeof top !== 'undefined') {
          scrollTo = top - Math.round($thumbsViewport.height()/2) + Math.round($imgItem.height()/2) - 10; // 10 = padding

          $thumbsViewport.animate({
            scrollTop: scrollTo
          }, 250);
        }
      }

      function jumpToImg(hashCode) {
        var $imgItem = $thumbsList.find('.iov-list-view-id-' + hashCode);

        if ($imgItem.length) {
          $imgItem.click();
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
        },

        load: function() {
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
        $.each(config.data, function(index, collection) {
          $.each(collection.images, function(index, image) {
            var imgUrl = getIiifImageUrl(collection.iiifServer, image.id, null, config.galleryView.thumbsHeight),
                $imgItem = $('<li data-alt="' + image.label + '">');

            $imgItem.data('iov-gallery-view-id', hashCode(image.id));
            $thumbsList.append($imgItem.append('<a href="javascript:;"><img alt="' + image.label + '" src="' + imgUrl + '"></a>'));

            if ($.inArray('list', config.availableViews) !== -1) {
              $imgItem.on('click', function() {
                $.publish('iov-jump-to-list-view', $(this).data('iov-gallery-view-id'));
              });
            }
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

        load: function() {
          $.publish('iov-gallery-view-load');
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
        $.each(config.data, function(index, collection) {
          $.each(collection.images, function(index, image) {
            var $imgItem = $('<li data-alt="' + image.label + '">');

            $imgItem
              .data('iov-horizontal-view-id', hashCode(image.id))
              .data('iov-height', image.height)
              .data('iov-width', image.width)
              .data('iov-iiif-server', collection.iiifServer)
              .data('iov-iiif-image-id', image.id);

            $imgsList.append($imgItem.append('<a href="javascript:;"><img alt="' + image.label + '" src=""></a>'));

            if ($.inArray('list', config.availableViews) !== -1) {
              $imgItem.on('click', function() {
                $.publish('iov-jump-to-list-view', $(this).data('iov-horizontal-view-id'));
              });
            }

          });
        });

        $horizontalView.append($viewport.append($imgsList));
      }

      function loadHorizontalViewImages() {
        var height,
            imgsListWidth = 0,
            imgsList = $imgsList.find('li[data-horizontal-view-id!=""]');

        $viewport.detach();

        height = $horizontalView.innerHeight() - 20,

        $.each(imgsList, function(index, imgItem) {
          var $imgItem = $(imgItem),
              iiifServer = $imgItem.data('iov-iiif-server'),
              id = $imgItem.data('iov-iiif-image-id'),
              imgUrl = getIiifImageUrl(iiifServer, id, null, height);

          $imgItem.find('img').attr('src', imgUrl);
          imgsListWidth += Math.round(($imgItem.data('iov-width') * height) / $imgItem.data('iov-height')) + 10;
        });

        $imgsList.width(imgsListWidth);
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

        load: function() {
          $.publish('iov-horizontal-view-load');
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

/*
 * jQuery Tiny Pub/Sub
 * https://github.com/cowboy/jquery-tiny-pubsub
 *
 * Copyright (c) 2013 "Cowboy" Ben Alman
 * Licensed under the MIT license.
 */

(function($) {

  var o = $({});

  $.subscribe = function() {
    o.on.apply(o, arguments);
  };

  $.unsubscribe = function() {
    o.off.apply(o, arguments);
  };

  $.publish = function() {
    o.trigger.apply(o, arguments);
  };

}(jQuery));
