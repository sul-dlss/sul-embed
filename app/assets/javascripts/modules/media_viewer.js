//= require modules/thumb_slider
//= require video.js/video.js
//= require videojs-contrib-hls/videojs-contrib-hls.js
/*global ThumbSlider */
/*global videojs */

(function( global ) {
  'use strict';
  var Module = (function() {
    var restrictedOverlaySelector = '[data-location-restricted-overlay]';
    var restrictedMessageSelector = '[data-access-restricted-message]';
    var sliderObjectSelector = '[data-slider-object]';
    var restrictedText = '(Restricted)'
    var MAX_FILE_LABEL_LENGTH = 45;

    function restrictedTextMarkup(isLocationRestricted) {
      if(isLocationRestricted) {
        return '<span class="sul-embed-thumb-restricted-text">' + restrictedText + '</span> ';
      } else {
        return '';
      }
    }

    function durationMarkup(duration) {
      if(duration && duration.length > 0) {
        return ' (' + duration + ')';
      } else {
        return '';
      }
    }

    function maxFileLabelLength(isLocationRestricted) {
      if(isLocationRestricted)
        return MAX_FILE_LABEL_LENGTH - restrictedText.length;
      else
        return MAX_FILE_LABEL_LENGTH;
    }

    function truncateWithEllipsis(text, maxLen) {
      return text.substr(0, maxLen - 1) + (text.length > maxLen ? '&hellip;' : '');
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

        var isLocationRestricted = $(mediaDiv).data('location-restricted');
        var fileLabel = $(mediaDiv).data('file-label');
        var duration = $(mediaDiv).data('duration');
        thumbs.push(
          '<li class="' + thumbClass + activeClass + '">' +
            thumbnailIcon +
            '<div class="' + labelClass + '">' +
              restrictedTextMarkup(isLocationRestricted) +
              truncateWithEllipsis(fileLabel, maxFileLabelLength(isLocationRestricted)) +
              durationMarkup(duration) +
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

    function updateMediaSrcWithToken(mediaObject, token) {
      if(token === undefined) {
        return;
      }
      var sources = mediaObject.find('source');
      jQuery.each(sources, function(){
        var source = jQuery(this);
        var originalSrc = source.attr('src');
        if(!originalSrc.includes('stacks_token')) {
          source.prop('src', originalSrc + '?stacks_token=' + token);
        }
      });
    }

    function initializeVideoJSPlayer(mediaObject) {
      mediaObject.addClass('video-js vjs-default-skin');
      videojs(
        mediaObject.attr('id'),
        {
          html5: {
            hls: {
              withCredentials: true
            }
          }
        }
      );
    }

    function authCheckForMediaObject(mediaObject, completeCallback) {
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
          parentDiv.find('[data-auth-link]').hide();
        }

        if(data.status === 'success') {
          updateMediaSrcWithToken(mediaObject, data.token)
          initializeVideoJSPlayer(mediaObject);
        }

        if(typeof(completeCallback) === 'function') {
          completeCallback(mediaObject, data);
        }
      });
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
            authCheckForMediaObject(mediaObject, function(_, data) {
              if(data.status === 'success') {
                clearInterval(checkWindow);
              }
            });
            return;
          }, 500);
        });
    }

    function authCheck() {
      jQuery('.sul-embed-media [data-auth-url]').each(function(){
        authCheckForMediaObject(jQuery(this));
      });
    }

    return {
      init: function() {
        setupThumbSlider();
        authCheck();
      }
    };
  })();

  global.MediaViewer = Module;
})(this);
