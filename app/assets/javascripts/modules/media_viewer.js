//= require modules/thumb_slider
/*global ThumbSlider */
/*global dashjs */

(function( global ) {
  'use strict';
  var Module = (function() {
    function thumbsForSlider() {
      var thumbs = [];
      var sliderSelector = '.sul-embed-media [data-slider-object]';
      jQuery(sliderSelector).each(function(index, mediaDiv) {
        var mediaObject = $(mediaDiv).find('audio, video');
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

        var thumbClass = 'sul-embed-slider-thumb sul-embed-media-slider-thumb ';
        var labelClass = 'sul-embed-thumb-label';

        if ($(mediaDiv).data('stanford-only')) {
          labelClass += ' sul-embed-thumb-stanford-only';
        }

        thumbs.push(
          '<li class="' + thumbClass + activeClass + '">' +
            '<i class="' + cssClass + '"></i>' +
            '<div class="' + labelClass + '">' +
              $(mediaDiv).data('file-label') +
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

    function _timedOut(start, time) {
      if ((Date.now() - start) < time) {
        return false;
      } else {
        return true;
      }
    }

    function authLink(loginService, mediaObject) {
      return jQuery('<a></a>')
        .prop('href', loginService['@id'])
        .prop('target', '_blank')
        .text(loginService.label)
        .on('click', function(e) {
          e.preventDefault();
          var windowReference = window.open(jQuery(this).prop('href'));

          var start = Date.now();
          var checkWindow = setInterval(function() {
            if (!_timedOut(start, 30000) &&
              (!windowReference || !windowReference.closed)) return;
            clearInterval(checkWindow);
            mediaObject[0].load();
            mediaObject
              .parent('[data-slider-object]')
              .find('[data-auth-link]')
              .hide();
            return;
          }, 500);
        });
    }


    function authCheck() {
      jQuery('.sul-embed-media [data-auth-url]').each(function(){
        var mediaObject = jQuery(this);
        var authUrl = mediaObject.data('auth-url');
        jQuery.ajax({url: authUrl, dataType: 'jsonp'}).done(function(data) {
          // present the auth link if it's stanford restricted and the user isn't logged in
          if(jQuery.inArray('stanford_restricted', data.status) > -1) {
            var wrapper = jQuery('<div data-auth-link="true" class="sul-embed-auth-link"></div>');
            mediaObject.after(
              wrapper.append(authLink(data.service, mediaObject))
            );
          }

          // if the user authed successfully for the file, hide the restriction overlays
          var sliderSelector = '.sul-embed-media [data-slider-object]';
          var parentDiv = mediaObject.closest(sliderSelector);
          var isRestricted = parentDiv.data('stanford-only') || parentDiv.data('location-restricted');
          if(isRestricted && data.status === 'success') {
            parentDiv.find('[data-location-restricted-overlay]').hide();
            parentDiv.find('[data-access-restricted-message]').hide();
          }
        });
      });
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

    function initializeDashPlayerForAllVideos() {
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
        authCheck();
        this.initializeDashPlayer();
      },

      initializeDashPlayer: function() {
        if ( !canPlayHLS() ) {
          initializeDashPlayerForAllVideos();
        }
        removeAllMediaDataSrc();
      }
    };
  })();

  global.MediaViewer = Module;
})(this);
