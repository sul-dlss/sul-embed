(function( global ) {
  'use strict';
  var Module = (function() {
    var selector;

    var containerTemplate =
      jQuery(
        '<div class="sul-embed-thumb-slider-container"></div>'
      );

    var toggleControl =
      jQuery(
        '<button class="sul-i-navigation-show-more-1 sul-embed-thumb-slider-open-close"' +
          ' aria-expanded="false" aria-label="toggle thumbnail viewer">' +
        '</button>'
      );

    var thumbList =
      jQuery(
        '<div class="sul-embed-thumb-slider" style="display:none"' +
          ' aria-expanded="false">' +
          '<ul></ul>' +
        '</div>'
      );

    function hideInitialSliderObjects() {
      $('[data-slider-object]').each(function(index, object) {
        if(index !== 0) {
          $(object)
            .addClass('sul-embed-hidden-slider-object')
            .attr('aria-hidden', 'true');
        }
      });
    }

    function hidePanelIfNotMultiple(thumbnails) {
      if(thumbnails.length < 2 && thumbList.find('li').length === 0) {
        containerTemplate.hide();
        return;
      }
    }

    function toggleAriaAttributes() {
      if(toggleControl.attr('aria-expanded') === 'true') {
        toggleControl.attr('aria-expanded', 'false');
        thumbList.attr('aria-expanded', 'false');
      }else{
        toggleControl.attr('aria-expanded', 'true');
        thumbList.attr('aria-expanded', 'true');
      }
    }

    function addToggleControlBehavior() {
      toggleControl.on('click', function() {
        thumbList.slideToggle();
        toggleAriaAttributes();
      });
    }

    function appendSliderToFrame(frame) {
      var container = containerTemplate.append(toggleControl, thumbList);
      frame.append(container);
    }

    return {
      init: function(providedSelector, options) {
        this.options = options;
        selector = providedSelector;
        appendSliderToFrame(this.scrollFrame());
        hideInitialSliderObjects();
        addToggleControlBehavior();
        return this;
      },

      options: {},

      addThumbnailsToSlider: function(thumbnails) {
        hidePanelIfNotMultiple(thumbnails);
        var _this = this;

        $.each(thumbnails, function(index, thumbnail) {
          thumbnail = $(thumbnail);
          thumbnail.data('slider-index', index);
          thumbnail.on('click', function() {
            thumbList.find('li.active').removeClass('active');
            $(this).addClass('active');

            var sliderObjects = _this.scrollFrame()
                                     .find('[data-slider-object]');
            var sliderObject = _this.scrollFrame()
                                    .find('[data-slider-object="' + index + '"]');


            sliderObjects
              .addClass('sul-embed-hidden-slider-object')
              .attr('aria-hidden', 'true');
            sliderObject
              .removeClass('sul-embed-hidden-slider-object')
              .attr('aria-hidden', 'false');

            if(typeof _this.options.thumbClickCallback === 'function') {
              _this.options.thumbClickCallback();
            }
          });
          thumbList.find('ul').append(thumbnail);
        });
      },

      scrollFrame: function() {
        return $(selector);
      }
    };
  })();

  global.ThumbSlider = Module;

})( this );
