/*global Sly, LayoutStore, ManifestStore, PubSub, CanvasStore */

(function( global ) {
  'use strict';
  var ImageXViewer = (function() {
    var layoutStore = new LayoutStore();
    var manifestStore = new ManifestStore();
    var canvasStore;
    var contentArea;
    var dataAttributes;
    var druid;
    var $el;
    var $thumbSlider;
    var $thumbOpenClose;
    var $thumbSliderContainer;
    var thumbSliderSly;
    var $embedHeader;

    var _listenForActions = function() {
      PubSub.subscribe('manifestStateUpdated', function() {
        _setupThumbSlider();
        _updateImageCount();
        canvasStore = new CanvasStore({
            manifest: manifestStore.getState().manifest
          });
      });
      PubSub.subscribe('layoutStateUpdated', function() {
        // add content area reactions here.
      });
      PubSub.subscribe('updatePerspective', function(_, newPerspective) {
        if (newPerspective === 'overview') {
          PubSub.publish('updateBottomPanel', false);
        } else {
          PubSub.publish('updateBottomPanel', true);
        }
      });
      PubSub.subscribe('disableMode', function(_, mode) {
        $embedHeader.find('[data-sul-view-mode="' + mode + '"]')
          .addClass('sul-embed-hidden');
      });
      PubSub.subscribe('disableOverviewPerspective', function() {
        $embedHeader.find('[data-sul-view-perspective]')
          .addClass('sub-embed-hidden');
      });
      PubSub.subscribe('enableMode', function(_, mode) {
        $embedHeader.find('[data-sul-view-mode="' + mode + '"]')
          .removeClass('sul-embed-hidden');
      });
      PubSub.subscribe('enableOverviewPerspective', function() {
        $embedHeader.find('[data-sul-view-perspective]')
          .removeClass('sul-embed-hidden');
      });
      /**
       * Enable the bottomPanel in detail perspective and update Sly thumb
       * slider with an overview selected new canvas
       */
      PubSub.subscribe('canvasStateUpdated', function() {
        var canvasState = canvasStore.getState();
        if (canvasState.perspective === 'detail' &&
          layoutStore.getState().overviewPerspectiveAvailable) {
          PubSub.publish('updateBottomPanel', true);
        }
        var thumbItem = $thumbSlider
          .find('li[data-canvasid="' + canvasState.selectedCanvas + '"]');
        thumbSliderSly.activate(thumbItem[0]);
      });
      PubSub.subscribe('updateBottomPanel', function(_, status) {
        if (status) {
          _enableBottomPanel();
        } else {
          _disableBottomPanel();
        }
      });
    };

    var _updateImageCount = function() {
      var $itemCount = $el.parent().parent().find('.sul-embed-item-count');
      var numImages = manifestStore.getState().manifest.sequences[0].canvases
        .length;
      var text = numImages === 1 ? ' image' : ' images';
      $itemCount.text(numImages + text);
    };

    var _setupButtonListeners = function() {
      $embedHeader.find('[data-sul-view-mode]').on('click', function() {
        var mode = $(this).data().sulViewMode;
        PubSub.publish('updateMode', mode);
      });
      $embedHeader.find('[data-sul-view-perspective]').on('click', function() {
        var perspective = $(this).data().sulViewPerspective;
        PubSub.publish('updatePerspective', perspective);
      });
      $embedHeader.find('[data-sul-view-fullscreen="fullscreen"]')
        .on('click', function() {
          canvasStore.osd.setFullScreen(true);
      });
    };

    var _disableBottomPanel = function() {
      $thumbSliderContainer.fadeOut();
    };

    var _enableBottomPanel = function() {
      $thumbSliderContainer.fadeIn();
    };

    var _closeThumbSlider = function() {
      PubSub.publish('thumbSliderToggle');
      $thumbOpenClose.addClass('sul-i-rotate-180');
      $thumbSlider.slideUp();
    };

    var _openThumbSlider = function() {
      PubSub.publish('thumbSliderToggle');
      $thumbOpenClose.removeClass('sul-i-rotate-180');
      $thumbSlider.slideDown();
    };

    var _thumbSliderActions = function() {
      $thumbOpenClose.on('click', function() {
        if ($thumbOpenClose.hasClass('sul-i-rotate-180')) {
          _openThumbSlider();
        } else {
          _closeThumbSlider();
        }
      });
    };

    var _extractDruid = function() {
      if (typeof dataAttributes !== 'undefined' &&
        typeof dataAttributes.manifestUrl !== 'undefined') {
        druid = dataAttributes.manifestUrl.slice(25, 36);
      } else {
        throw new Error('Data attribute "data-manifest-url" is missing');
      }
    };

    var _requestManifest = function() {
      $.get(dataAttributes.manifestUrl)
        .done(function(data) {
          PubSub.publish('manifestDone', data);
        })
        .fail(function() {
          throw new Error('Could not access manifest.json');
        });
    };

    // http://upshots.org/javascript/jquery-test-if-element-is-in-viewport
    // -visible-on-screen
    var _isOnScreen = function(elem, outsideViewportFactor) {
      var factor = 1;
      if (outsideViewportFactor) {
        factor = outsideViewportFactor;
      }
      var win = jQuery(window);
      var viewport = {
        top : (win.scrollTop() * factor),
        left : (win.scrollLeft() * factor)
      };
      viewport.bottom = (viewport.top + win.height()) * factor;
      viewport.right = (viewport.left + win.width()) * factor;

      var el = jQuery(elem);
      var bounds = el.offset();
      bounds.bottom = bounds.top + el.height();
      bounds.right = bounds.left + el.width();

      return (!(viewport.right < bounds.left || viewport.left > bounds.right ||
        viewport.bottom < bounds.top || viewport.top > bounds.bottom));
    };

    var _loadImages = function(element) {
      $.each(element.find('img'), function(i, value) {
        if (_isOnScreen(value, 1.5) && !jQuery(value).attr('src')) {
          var url = $(value).data('src');
          $(value).attr('src', url);
        }
      });
    };

    var _disableClicks = function() {
      if (dataAttributes.worldRestriction) {
        $el.on('contextmenu', '.openseadragon-canvas', function(e) {
          e.preventDefault();
        });
      }
    };

    var _setupThumbSlider = function() {
      
      var thumbHeight = 100;
      var thumbDisplayHeight = 75;
      var manifest = manifestStore.getState().manifest;
      var canvases = manifest.sequences[0].canvases;
      if (canvases.length > 1) {
        PubSub.publish('enableMode', 'individuals');
        PubSub.publish('enableOverviewPerspective');
        if (manifest.viewingHint && manifest.viewingHint === 'paged') {
          PubSub.publish('enableMode', 'paged');
        }
      } else {
        return;
      }

      // Create dom base elements
      $thumbSliderContainer = $(document.createElement('div'));
      $thumbSliderContainer.
        addClass('sul-embed-image-x-thumb-slider-container');
      $thumbSlider = $(document.createElement('div'));
      $thumbSlider.addClass('sul-embed-image-x-thumb-slider');
      $thumbOpenClose = $(document.createElement('div'));
      $thumbOpenClose.addClass('sul-i-arrow-down-8 ' +
        'sul-embed-image-x-thumb-slider-open-close');
      _thumbSliderActions();//$openClose, $thumbSlider);
      var $thumbSliderScroll = $(document.createElement('div'));
      $thumbSliderScroll.addClass('sul-embed-thumb-slider-scroll');
      var $handle = $(document.createElement('div'));
      $handle.addClass('sul-embed-thumb-slider-handle');
      var $mousearea = $(document.createElement('div'));
      $mousearea.addClass('sul-embed-thumb-slider-mousearea');
      $handle.append($mousearea);
      $thumbSliderScroll.append($handle);
      var $thumbSliderList = $(document.createElement('ul'));

      $.each(canvases, function(i, val) {
        var id = val.images[0].resource.service['@id'];
        var canvasId = val['@id'];
        // Create base <li> element, then adds the image and label to it in a
        // performant way
        var $thumb = $(document.createElement('li'));
        $thumb.addClass('sul-embed-image-x-thumb');
        $thumb.attr('data-id', id);
        $thumb.attr('data-canvasId', canvasId);
        $thumb.attr('title', val.label);
        var aspectRatio = val.width / val.height;
        $thumb.width(Math.ceil(thumbDisplayHeight * aspectRatio));
        var $image = $(document.createElement('img'));
        $image.attr('data-src', id + '/full/' +
          Math.ceil(thumbHeight * aspectRatio * 2) + ',/0/default.jpg');
        $image.height(thumbDisplayHeight);
        var $label = $(document.createElement('div'));
        $label.text(val.label);
        $label.addClass('sul-embed-image-x-label');
        $thumb.append([$image, $label]);
        $thumbSliderList.append($thumb);
      });

      // Append everything together
      $thumbSlider.append($thumbSliderList);
      $thumbSliderContainer.append([$thumbOpenClose, $thumbSlider,
        $thumbSliderScroll]);
      $el.after($thumbSliderContainer);

      thumbSliderSly = new Sly($thumbSlider, {
        horizontal: 1,
        itemNav: 'forceCentered',
        smart: 1,
        activateMiddle: 1,
        activateOn: 'click',
        mouseDragging: 1,
        touchDragging: 1,
        releaseSwing: 1,
        scrollBar: $thumbSliderScroll,
        dragHandle: 1,
        dynamicHandle: 1,
        startAt: 0,
        speed: 300,
        elasticBounds: 1
      }).init();

      _loadImages($thumbSlider);

      thumbSliderSly.on('load move', function() {
        _loadImages($thumbSlider);
      });

      thumbSliderSly.on('active', function(e, i) {
        var id = $($thumbSliderList.find('li')[i]).data('canvasid');
        PubSub.publish('currentImageUpdated', id);
      });
    };

    return {
      init: function() {
        $el = $('#sul-embed-image-x');

        // Access data attributes
        dataAttributes = $el.data();
        $embedHeader = $el.parent().parent();

        _setupButtonListeners();
        _listenForActions();

        _extractDruid();

        // Request IIIF manifest
        _requestManifest();
        _disableClicks();
      }
    };
  })();

  global.ImageXViewer = ImageXViewer;
})(this);
