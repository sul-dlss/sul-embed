/*global Sly, LayoutStore, ManifestStore, PubSub */

(function( global ) {
  'use strict';
  var ImageXViewer = (function() {
    var layoutStore = new LayoutStore();
    var manifestStore = new ManifestStore();
    var dataAttributes;
    var druid;
    var $el;
    var thumbSliderSly;

    var _listenForActions = function() {
      PubSub.subscribe('manifestStateUpdated', function() {
        _setupThumbSlider();
      });
    };

    var _thumbSliderActions = function($element, $slider) {
      $element.on('click', function() {
        PubSub.publish('thumbSliderToggle');
        if ($element.hasClass('sul-i-rotate-180')) {
          $element.removeClass('sul-i-rotate-180');
        } else {
          $element.addClass('sul-i-rotate-180');
        }
        $slider.slideToggle();
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
      $.get('/teaspoon/fixtures/manifest.json')
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
    
    var _setupThumbSlider = function() {
      var thumbSize = 100;

      // Create dom base elements
      var $thumbSliderContainer = $(document.createElement('div'));
      $thumbSliderContainer.
        addClass('sul-embed-image-x-thumb-slider-container');
      var $thumbSlider = $(document.createElement('div'));
      $thumbSlider.addClass('sul-embed-image-x-thumb-slider');
      var $openClose = $(document.createElement('div'));
      $openClose.addClass('sul-i-arrow-down-8 ' + 
        'sul-i-2x sul-embed-image-x-thumb-slider-open-close');
      _thumbSliderActions($openClose, $thumbSlider);
      var $thumbSliderScroll = $(document.createElement('div'));
      $thumbSliderScroll.addClass('sul-embed-image-x-thumb-slider-scroll');
      var $handle = $(document.createElement('div'));
      $handle.addClass('sul-embed-image-x-thumb-slider-handle');
      var $mousearea = $(document.createElement('div'));
      $mousearea.addClass('sul-embed-image-x-thumb-slider-mousearea');
      $handle.append($mousearea);
      $thumbSliderScroll.append($handle);
      var $thumbSliderList = $(document.createElement('ul'));

      var canvases = manifestStore.manifestState.manifest.sequences[0].canvases;
      $.each(canvases, function(i, val) {
        var id = val.images[0].resource.service['@id'];
        // Create base <li> element, then adds the image and label to it in a
        // performant way
        var $thumb = $(document.createElement('li'));
        $thumb.addClass('sul-embed-image-x-thumb');
        $thumb.attr('data-id', id);
        $thumb.width((val.width * thumbSize) / val.height);
        var $image = $(document.createElement('img'));
        $image.attr('data-src', id + '/full/,' + thumbSize * 2 +
          '/0/default.jpg');
        $image.height(thumbSize);
        var $label = $(document.createElement('div'));
        $label.text(val.label);
        $label.addClass('sul-embed-image-x-label');
        $thumb.append([$image, $label]);
        $thumbSliderList.append($thumb);
      });

      // Append everything together
      $thumbSlider.append($thumbSliderList);
      $thumbSliderContainer.append([$openClose, $thumbSlider,
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
        var id = $($thumbSliderList.find('li')[i]).data('id');
        PubSub.publish('currentImageUpdated', id);
      });
    };

    return {
      init: function() {
        $el = $('#sul-embed-image-x');

        // Access data attributes
        dataAttributes = $el.data();

        _listenForActions();

        _extractDruid();

        // Request IIIF manifest
        _requestManifest();
      }
    };
  })();

  global.ImageXViewer = ImageXViewer;
})(this);
