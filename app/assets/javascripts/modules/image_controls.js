/*global PubSub */

(function(global) {
  'use strict';

  // Handles the display of the image controls in image viewer
  var ImageControls = (function() {
    var $imageControls;
    var $fullscreen;
    var $pagedMode;
    var $individualsMode;
    var $overviewPerspective;

    return {
      render: function(layout, canvas) {
        layout = typeof layout !== 'undefined' ?  layout : {};
        canvas = typeof canvas !== 'undefined' ?  canvas : {};

        // Fullscreen
        if (layout.fullscreen) {
          $fullscreen.removeAttr('disabled');
        } else {
          $fullscreen.attr('disabled', '');
        }

        // Modes
        if (layout.individuals) {
          $individualsMode.removeClass('sul-embed-hidden');
        }
        if (layout.paged) {
          $pagedMode.removeClass('sul-embed-hidden');
        }

        // Perspective
        if (layout.overviewPerspectiveAvailable) {
          $overviewPerspective.removeClass('sul-embed-hidden');
        }

        if (canvas.perspective === 'overview') {
          $individualsMode.removeClass('active');
          $pagedMode.removeClass('active');
          $overviewPerspective.addClass('active');
        } else {
          $overviewPerspective.removeClass('active');
          if (canvas.viewingMode === 'individuals') {
            $pagedMode.removeClass('active');
            $individualsMode.addClass('active');
          } else {
            $individualsMode.removeClass('active');
            $pagedMode.addClass('active');
          }
        }
      },
      init: function($el) {
        $imageControls = $el;
        $fullscreen = $el.find('[data-sul-view-fullscreen]');
        $pagedMode = $el.find('[data-sul-view-mode="paged"]');
        $individualsMode = $el.find('[data-sul-view-mode="individuals"]');
        $overviewPerspective = $el.find('[data-sul-view-perspective]');
        
        // Handle control events here, but unfortunately we cannot handle the 
        // fullscreen through PubSub because of browser security restrictions
        $pagedMode.on('click', function() {
          var mode = $(this).data().sulViewMode;
          PubSub.publish('updateMode', mode);
        });
        
        $individualsMode.on('click', function() {
          var mode = $(this).data().sulViewMode;
          PubSub.publish('updateMode', mode);
        });
        
        $overviewPerspective.on('click', function() {
          PubSub.publish('updatePerspective', 'overview');
        });

        return this;
      },
      _paged: function() {
        return $pagedMode;
      },
      _individuals: function() {
        return $individualsMode;
      },
      _fullscreen: function() {
        return $fullscreen;
      },
      _overview: function() {
        return $overviewPerspective;
      }
    };
  })();
  

  global.ImageControls = ImageControls;
})(this);
