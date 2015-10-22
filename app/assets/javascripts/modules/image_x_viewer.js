/*global Sly, LayoutStore, ManifestStore, PubSub, CanvasStore, key, sulEmbedDownloadPanel, ImageControls */

(function( global ) {
  'use strict';
  var ImageXViewer = (function() {
    var layoutStore = new LayoutStore();
    var manifestStore = new ManifestStore();
    var canvasStore;
    var dataAttributes;
    var druid;
    var $el;
    var $thumbSlider;
    var $thumbOpenClose;
    var $thumbSliderContainer;
    var thumbSliderSly;
    var $embedHeader;
    var imageControls;

    var _listenForActions = function() {
      PubSub.subscribe('manifestStateUpdated', function() {
        _setupThumbSlider();
        _setupKeyListeners();
        _updateImageCount();
        canvasStore = new CanvasStore({
            manifest: manifestStore.getState().manifest
          });
        _updateDownloadPanel(canvasStore.getState().selectedCanvas);
        _addLeftRightControls();
      });
      PubSub.subscribe('layoutStateUpdated', function() {
        // add content area reactions here.
      });
      PubSub.subscribe('thumbSliderToggled', function() {
        var state = layoutStore.getState();
        if (state.bottomPanelOpen) {
          PubSub.publish('updateKeyboardMode', 'bottomPanelOpen');
        } else {
          PubSub.publish('updateKeyboardMode', 'bottomPanelClosed');
        }
      });
      PubSub.subscribe('keyboardModeUpdated', function() {
        var state = layoutStore.getState();
        key.setScope(state.keyboardNavMode);
      });
      PubSub.subscribe('updatePerspective', function(_, newPerspective) {
        if (newPerspective === 'overview') {
          PubSub.publish('updateBottomPanel', false);
          PubSub.publish('updateKeyboardMode', 'overview');
        } else {
          PubSub.publish('updateBottomPanel', true);
        }
      });
      PubSub.subscribe('disableFullscreen', function() {
        imageControls.render(layoutStore.getState(), canvasStore.getState());
      });
      PubSub.subscribe('enableFullscreen', function() {
        imageControls.render(layoutStore.getState(), canvasStore.getState());
      });
      PubSub.subscribe('disableMode', function() {
        imageControls.render(layoutStore.getState(), canvasStore.getState());
      });
      PubSub.subscribe('enableMode', function() {
        imageControls.render(layoutStore.getState(), canvasStore.getState());
      });
      PubSub.subscribe('enableOverviewPerspective', function() {
        imageControls.render(layoutStore.getState(), canvasStore.getState());
      });
      /**
       * Enable the bottomPanel in detail perspective and update Sly thumb
       * slider with an overview selected new canvas
       */
      PubSub.subscribe('canvasStateUpdated', function() {
        var canvasState = canvasStore.getState();
        if (canvasState.perspective === 'detail') {
          PubSub.publish('enableFullscreen');
          if (layoutStore.getState().overviewPerspectiveAvailable) {
            PubSub.publish('updateBottomPanel', true);
          }
        } else {
          PubSub.publish('disableFullscreen');
        }
        var thumbItem = $thumbSlider
          .find('li[data-canvasid="' + canvasState.selectedCanvas + '"]');
        thumbSliderSly.activate(thumbItem[0]);
        _updateDownloadPanel(canvasState.selectedCanvas);
      });
      PubSub.subscribe('updateBottomPanel', function(_, status) {
        if (status) {
          _enableBottomPanel();
        } else {
          _disableBottomPanel();
        }
      });
    };

    /**
     * Requests the selectedCanvas's info.json and updates the download panel
     * @param {String} selectedCanvas
     */
    var _updateDownloadPanel = function(selectedCanvas) {
      var manifest = manifestStore.getState().manifest;
      manifest.sequences[0].canvases.forEach(function(canvas) {
        if (selectedCanvas === canvas['@id']) {
          $.getJSON(canvas.images[0].resource.service['@id'] + '/info.json',
            function(data) {
              sulEmbedDownloadPanel.update(
                data, canvas.label, dataAttributes.worldRestriction
              );
          });
          return;
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

    var _addLeftRightControls = function() {
      // Do not add left/right controls on single images
      var manifest = manifestStore.getState().manifest;
      if (manifest.sequences[0].canvases.length < 2) { return; }

      var $leftControl = $('<div class="sul-embed-image-x-side-control sul-em' +
        'bed-image-x-side-control-left" aria-label="next image"><div class=su' +
        'l-i-arrow-left-8></div></div>');
      var $rightControl = $('<div class="sul-embed-image-x-side-control sul-e' +
        'mbed-image-x-side-control-right" aria-label="previous image"><div cl' +
        'ass=sul-i-arrow-right-8></div></div>');
      $el.append($leftControl, $rightControl);
      $leftControl.on('click', function() {
        canvasStore.previous();
      });
      $rightControl.on('click', function() {
        canvasStore.next();
      });
      var timeout;
      // Show controls for 2 seconds when mouse stops moving
      $el.on('mousemove', function() {
        // Do not show controls in overview perspective
        var canvasState = canvasStore.getState();
        if (canvasState.perspective === 'overview') { return; }
        $leftControl.stop();
        $rightControl.stop();
        $leftControl.fadeIn(200);
        $rightControl.fadeIn(200);
        clearTimeout(timeout);
        timeout = setTimeout(function() {
          $leftControl.fadeOut(2000);
          $rightControl.fadeOut(2000);
        }, 1000);
      });
    };

    var _setupButtonListeners = function() {
      $embedHeader.find('[data-sul-view-fullscreen="fullscreen"]')
        .on('click', function() {
          canvasStore.osd.setFullScreen(true);
      });
    };

    var _setupKeyListeners = function() {

      key('left', 'bottomPanelOpen', function() {
        canvasStore.previous();
      });

      key('right', 'bottomPanelOpen', function() {
        canvasStore.next();
      });

      key('left', 'bottomPanelClosed', function() {
        canvasStore.previous();
      });

      key('right', 'bottomPanelClosed', function() {
        canvasStore.next();
      });

      key('left', 'overview', function() {
        canvasStore.previous();
      });

      key('right', 'overview', function() {
        canvasStore.next();
      });

      PubSub.publish('updateKeyboardMode', 'bottomPanelOpen');
    };

    var _disableBottomPanel = function() {
      $thumbSliderContainer.fadeOut();
    };

    var _enableBottomPanel = function() {
      $thumbSliderContainer.fadeIn();
    };

    var _closeThumbSlider = function() {
      PubSub.publish('thumbSliderToggle');
      $thumbOpenClose.removeClass('open');
      $thumbOpenClose.attr('aria-expanded', false);
      $thumbSlider.slideUp();
    };

    var _openThumbSlider = function() {
      PubSub.publish('thumbSliderToggle');

      $thumbOpenClose.addClass('open');
      $thumbOpenClose.attr('aria-expanded', true);
      $thumbSlider.slideDown();
    };

    var _thumbSliderActions = function() {
      $thumbOpenClose.on('click', function() {
        if ($thumbOpenClose.hasClass('open')) {
          _closeThumbSlider();
        } else {
          _openThumbSlider();
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
        .fail(function(e) {
          if (e.status === 404) {
            _noImagesAvailable();
          }
          throw new Error('Could not access manifest.json');
        });
    };

    var _noImagesAvailable = function() {
      // Append the no image to view message
      $el.append($('<div class="sul-embed-image-x-well"><div class="sul-embed' +
        '-image-x-well-content">There are no images to view</div><div>'));
      // Animate the height down to something reasonable
      $el.parent().animate({
        height: '100%'
      });
      _hideDownloadButton();
    };

    var _hideDownloadButton = function() {
      // Hide the download panel button
      $($el.parent().parent().find('[data-sul-embed-toggle="sul-embed-downloa' +
        'd-panel"]')).hide();
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
      $thumbOpenClose.addClass('sul-i-navigation-show-more-1 open ' +
        'sul-embed-image-x-thumb-slider-open-close');
      $thumbOpenClose.attr('aria-label', 'toggle thumbnail viewer');
      $thumbOpenClose.attr('aria-expanded', true);
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
        $image.attr('alt', '');
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
        syncSpeed: 0,
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
        imageControls = ImageControls.init($embedHeader);
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
