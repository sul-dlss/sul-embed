'use strict';

import ThumbSlider from './thumb_slider.js';
import videojs from 'video.js';

export default (function() {
    const restrictedMessageSelector = '[data-access-restricted-message]';
    const sliderObjectSelector = '[data-slider-object]';
    const restrictedText = '(Restricted)';
    const MAX_FILE_LABEL_LENGTH = 45;

    function restrictedTextMarkup(isLocationRestricted) {
      if(isLocationRestricted) {
        return `<span class="sul-embed-location-restricted-text">${restrictedText}</span>`
      } else {
        return '';
      }
    }

    function stanfordOnlyScreenreaderText(isStanfordRestricted) {
      if(isStanfordRestricted) {
        return '<span class="sul-embed-text-hide">Stanford only</span>';
      }else{
        return '';
      }
    }

    function durationMarkup(duration) {
      if(duration && duration.length > 0) {
        return ` (${duration})`
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
      const thumbs = [];
      const sliderSelector = `[data-behavior="legacy-media"] ${sliderObjectSelector}`
      document.querySelectorAll(sliderSelector).forEach(function(mediaDiv, index) {
        const mediaObject = $(mediaDiv).find('audio, video');
        let cssClass;
        if(mediaObject.prop('tagName') === 'AUDIO') {
          cssClass = 'sul-i-file-music-1';
        } else {
          cssClass = 'sul-i-file-video-3';
        }

        let activeClass = '';
        if (index === 0) {
          activeClass = 'active';
        }

        const thumbClass = 'sul-embed-slider-thumb sul-embed-media-slider-thumb ';
        let labelClass = 'sul-embed-thumb-label';
        const isStanfordRestricted = mediaDiv.dataset.stanfordOnly === "true"
        if (isStanfordRestricted) {
          labelClass += ' sul-embed-thumb-stanford-only';
        }

        let thumbnailIcon = '';
        const thumbnailUrl = mediaDiv.dataset.thumbnailUrl
        if (thumbnailUrl !== '') {
          thumbnailIcon = '<img class="sul-embed-media-square-icon" src="' + thumbnailUrl + '" />';
        } else {
          thumbnailIcon = '<i class="' + cssClass + '"></i>';
        }

        const isLocationRestricted = mediaDiv.dataset.locationRestricted === "true"
        const fileLabel = String(mediaDiv.dataset.fileLabel || '');
        const duration = String(mediaDiv.dataset.duration || '');
        thumbs.push(
          `<li class="${thumbClass}${activeClass}">${thumbnailIcon}
            <a class="#{labelClass}" href="#">
              ${stanfordOnlyScreenreaderText(isStanfordRestricted)}
              ${restrictedTextMarkup(isLocationRestricted)}
              ${truncateWithEllipsis(fileLabel, maxFileLabelLength(isLocationRestricted))}
              ${durationMarkup(duration)}
            </a></li>`
        );
      });

      return thumbs;
    }

    function pauseAllMedia() {
      const mediaObjects = document.querySelectorAll('[data-behavior="legacy-media"] .video-js')
      mediaObjects.forEach(function(node) {
        videojs(node.id).pause();
      });
    }

    function setupThumbSlider() {
      ThumbSlider
        .init('[data-behavior="legacy-media"]', { thumbClickCallback: pauseAllMedia })
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
      const sources = mediaObject.querySelectorAll('source');
      sources.forEach(function(source){
        const originalSrc = source.getAttribute('src');
        if(originalSrc.indexOf('stacks_token') < 0) {
          source.setAttribute('src', `${originalSrc}?stacks_token=${token}`);
        }
      });
    }

    function initializeVideoJSPlayer(mediaObject) {
      mediaObject.classList.add('video-js', 'vjs-default-skin');
      const vjs = videojs(mediaObject.id);
      vjs.removeChild('textTrackSettings')
    }

    function authCheckForMediaObject(mediaObject, completeCallback) {
      const authUrl = mediaObject.dataset.authUrl
      jQuery.ajax({url: authUrl, dataType: 'jsonp'}).done(function(data) {
        // present the auth link if it's stanford restricted and the user isn't logged in
        if(jQuery.inArray('stanford_restricted', data.status) > -1) {
          const wrapper = jQuery('<div data-auth-link="true" class="sul-embed-auth-link"></div>');
          $(mediaObject).parents(sliderObjectSelector).append(
            wrapper.append(authLink(data.service, mediaObject))
          );
        }

        // if the user authed successfully for the file, hide the restriction overlays
        const sliderSelector = `[data-behavior="legacy-media"] ${sliderObjectSelector}`
        const parentDiv = mediaObject.closest(sliderSelector);
        const isRestricted = parentDiv.dataset.stanfordOnly === "true" || 
          parentDiv.dataset.locationRestricted === "true"
        if (isRestricted && data.status === 'success') {
          parentDiv.querySelector(restrictedMessageSelector).hidden = true
          const authLink = parentDiv.querySelector('[data-auth-link]')
          if (authLink)
            authLink.hidden = true
        }

        if(data.status === 'success') {
          updateMediaSrcWithToken(mediaObject, data.token);
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
          const windowReference = window.open(jQuery(this).prop('href'));

          const start = Date.now();
          const checkWindow = setInterval(function() {
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
      document.querySelectorAll('[data-behavior="legacy-media"] [data-auth-url]').
        forEach((mediaObject) => authCheckForMediaObject(mediaObject));
    }

    return {
      init: function() {
        setupThumbSlider();
        authCheck();
      }
    };
  })();
