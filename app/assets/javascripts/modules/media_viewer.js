//= require modules/thumb_slider
/*global ThumbSlider */
/*global dashjs */

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

    function loadDashPlayerJavascript(callback) {
      var playerJS = jQuery('[data-sul-embed-dash-player]')
                       .data('sul-embed-dash-player');

      jQuery.getScript(playerJS).done(callback);
    }

    // canPlayType() returns 'probably', 'maybe', or ''
    function canPlayHLS() {
      var hlsMimeType = 'application/vnd.apple.mpegURL';
      var tempVideo = document.createElement('video');
      var canPlayTypsHLS = tempVideo.canPlayType(hlsMimeType);
      return canPlayTypsHLS !== '';
    }

    function removeAllMediaDataSrc() {
      jQuery('.sul-embed-media audio, .sul-embed-media video').each(function() {
        jQuery(this).removeAttr('data-src');
      });
    }

    function preloadVideoUrls() {
      jQuery('.sul-embed-media video').each(function() {
        $(this).data('src');
      });
    }

    function initialzeDashPlayerForAllVideos() {
      preloadVideoUrls();
      loadDashPlayerJavascript(function() {
        jQuery('.sul-embed-media video').each(function() {
          var url = jQuery(this).data('src');
          var player = dashjs.MediaPlayer().create();
          player.initialize(this, url, false);
        });
      });
    }

    return {
      init: function() {
        setupThumbSlider();
        this.initialzeDashPlayer();
      },

      initialzeDashPlayer: function() {
        if ( !canPlayHLS() ) {
          initialzeDashPlayerForAllVideos();
        }
        removeAllMediaDataSrc();
      }
    };
  })();

  global.MediaViewer = Module;
})(this);
