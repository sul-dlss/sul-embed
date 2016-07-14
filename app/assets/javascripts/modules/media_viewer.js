//= require modules/thumb_slider
/*global ThumbSlider */
/*global dashjs */

(function( global ) {
  'use strict';
  var Module = (function() {
    var restrictedOverlaySelector = '[data-location-restricted-overlay]';
    var restrictedMessageSelector = '[data-access-restricted-message]';
    var sliderObjectSelector = '[data-slider-object]';
    var restrictedText = '(Restricted)'

    function restrictedTextMarkup(isLocationRestricted) {
      if(isLocationRestricted) {
        return '<span class="sul-embed-thumb-restricted-text">' + restrictedText + '</span> ';
      } else {
        return '';
      }
    }

    function thumbsForSlider() {
      var thumbs = [];
      var sliderSelector = '.sul-embed-media ' + sliderObjectSelector;
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

        var thumbnailIcon = '';
        var thumbnailUrl = $(mediaDiv).data('thumbnail-url');
        if (thumbnailUrl !== '') {
          thumbnailIcon = '<img class="sul-embed-media-square-icon" src="' + thumbnailUrl + '" />';
        } else {
          thumbnailIcon = '<i class="' + cssClass + '"></i>';
        }

        thumbs.push(
          '<li class="' + thumbClass + activeClass + '">' +
            thumbnailIcon +
            '<div class="' + labelClass + '">' +
              restrictedTextMarkup($(mediaDiv).data('location-restricted')) +
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
            mediaObject
              .parents(sliderObjectSelector)
              .find('[data-auth-link], ' + restrictedOverlaySelector + ', ' + restrictedMessageSelector)
              .hide();
            // As best I can tell, .touch() does nothing (and does not exist in jQuery),
            // but without calling some function after .load() the media fails to load.
            mediaObject[0].load().touch();
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
            mediaObject.parents(sliderObjectSelector).append(
              wrapper.append(authLink(data.service, mediaObject))
            );
          }

          // if the user authed successfully for the file, hide the restriction overlays
          var sliderSelector = '.sul-embed-media ' + sliderObjectSelector;
          var parentDiv = mediaObject.closest(sliderSelector);
          var isRestricted = parentDiv.data('stanford-only') || parentDiv.data('location-restricted');
          if(isRestricted && data.status === 'success') {
            parentDiv.find(restrictedOverlaySelector).hide();
            parentDiv.find(restrictedMessageSelector).hide();
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
          player.setXHRWithCredentials(true);
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
