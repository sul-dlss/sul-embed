/*global */

(function(global) {
  'use strict';

  // Handles the checking for IiifAuth status in JavaScript
  var IiifAuth = function(authUrl) {
    var _IiifAuthUrl = authUrl;
    var _accessToken = null;
    var _authStatus = false;
    var _messageId = 0;

    this.authenticated = function() {
      return _authStatus;
    };

    /**
     * IIIF auth access token
     * @returns {String|null}
     */
    this.accessToken = function() {
      return _accessToken;
    };
    
    this.nextMessageId = function() {
      return ++_messageId;
    };

    /**
     * Check IIIF authentication status
     * @returns {Function} [callback] - Optional callback to be called after
     * ajax completes (or fails)
     */
    this.checkStatus = function(callback) {
      var messageId = this.nextMessageId();
      
      var messageHandler = function(event) {
        var data = event.data;

        if (!data.hasOwnProperty('messageId') || data.messageId != messageId) {
          return;
        }

        if (data.hasOwnProperty('accessToken')) {
          _accessToken = data.accessToken;
          _authStatus = true;
          if ($.isFunction(callback)) {
            callback(_authStatus);
          }
        } else {
          if ($.isFunction(callback)) {
            callback(false);
          }
        }
      };

      window.addEventListener("message", messageHandler);

      var url = _IiifAuthUrl + "?messageId=" + messageId + "&origin=" + this.origin();
      var iframe = $('<iframe></iframe>');
      iframe.attr('src', url);
      iframe.hide();
      $('body').append(iframe);
    };
    
    this.origin = function() {
      var location = window.location;
      return location.protocol + "//" + location.host + "/";
    };
  };

  global.IiifAuth = IiifAuth;
})(this);
