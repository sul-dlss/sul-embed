//= require modules/thumb_slider
/*global ThumbSlider */

(function( global ) {
  'use strict';
  var Module = (function() {
    function thumbsForSlider() {
      var thumbs = [];
      $('.sul-embed-media video, .sul-embed-media audio').each(function(index, mediaObject) {
        mediaObject = $(mediaObject);
        var cssClass;
        if(mediaObject.prop('tagName') === 'AUDIO') {
          cssClass = 'sul-i-file-music-1';
        } else {
          cssClass = 'sul-i-file-video-3';
        }

        var activeClass = '';
        if (index === 0) {
          activeClass = 'active';
        }

        thumbs.push(
          '<li class="sul-embed-slider-thumb ' + activeClass + '">' +
            '<i class="' + cssClass + '"></i>' +
            '<div class="sul-embed-thumb-label">' +
              mediaObject.data('file-label') +
            '</div>' +
          '</li>'
        );
      });

      return thumbs;
    }

    function pauseAllMedia() {
      var mediaObjects = $('.sul-embed-media audio, .sul-embed-media video');
      mediaObjects.each(function() {
        this.pause();
      });
    }

    function setupThumbSlider() {
      ThumbSlider
        .init('.sul-embed-media', { thumbClickCallback: pauseAllMedia })
        .addThumbnailsToSlider(thumbsForSlider());
    }

    return {
      init: function() {
        setupThumbSlider();
      }
    };
  })();

  global.MediaViewer = Module;
})(this);
