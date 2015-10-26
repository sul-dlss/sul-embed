/*global */

(function(global) {
  'use strict';

  // Handles the checking for IiifAuth status in JavaScript
  var IiifAuth = function(authUrl) {
    var _IiifAuthUrl = authUrl;
    var _accessToken = null;
    var _authStatus = false;

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

    /**
     * Check IIIF authentication status
     * @returns {Function} [callback] - Optional callback to be called after
     * ajax completes (or fails)
     */
    this.checkStatus = function(callback) {
      $.ajax({
        url: _IiifAuthUrl,
        dataType: 'jsonp'
      })
      .done(function(data) {
        if (data.accessToken) {
          _accessToken = data.accessToken;
          _authStatus = true;
          return;
        }
      })
      .always(function(){
        if ($.isFunction(callback)) {
          callback(_authStatus);
        }
      });
    };
  };

  global.IiifAuth = IiifAuth;
})(this);
