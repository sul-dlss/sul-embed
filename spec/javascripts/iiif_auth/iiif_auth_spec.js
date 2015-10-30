/*global IiifAuth */

//= require jquery
//= require support/jquery.mockjax
//= require modules/iiif_auth

'use strict';

describe('IiifAuth', function() {
  describe('loads and makes available modules', function() {
    it('IiifAuth is defined', function() {
      expect(IiifAuth).toBeDefined();
    });
  });
  describe('default values', function() {
    var w;
    beforeEach(function() {
      w = new IiifAuth('http://www.example.com');
    });
    it('authStatus is false', function() {
      expect(w.authenticated()).toBe(false);
    });
    it('authStatus is private', function() {
      expect(w._authStatus).toBeUndefined();
    });
  });
  describe('checkStatus', function() {
    var w;
    describe('when not authenticated', function() {
      beforeEach(function() {
        $.mockjax({
          url: 'http://www.example.com',
          responseText: {
            status: 401
          }
        });
      });
      afterEach(function() {
        $.mockjax.clear();
      });
      it('authStatus should be false', function() {
        w = new IiifAuth('http://www.example.com');
        w.checkStatus(function(authStatus) {
          expect(authStatus).toBe(false);
        });
        expect(w.authenticated()).toBe(false);
        expect(w.accessToken()).toBe(null);
      });
    });
    describe('when response time > 300', function() {
      beforeEach(function() {
        $.mockjax({
          url: 'http://www.example.com',
          responseTime: 301,
          responseText: {
            status: 200
          }
        });
      });
      afterEach(function() {
        $.mockjax.clear();
      });
      it('authStatus should be false', function() {
        w = new IiifAuth('http://www.example.com');
        w.checkStatus(function(authStatus) {
          expect(authStatus).toBe(false);
        });
        expect(w.authenticated()).toBe(false);
        expect(w.accessToken()).toBe(null);
      });
    });
    describe('when successful with accessToken', function() {
      beforeEach(function() {
        $.mockjax({
          url: 'http://www.example.com',
          responseText: {
            status: 200,
            accessToken: 'authed'
          }
        });
      });
      afterEach(function() {
        $.mockjax.clear();
      });
      it('authStatus should be true', function() {
        w = new IiifAuth('http://www.example.com');
        w.checkStatus(function(authStatus) {
          expect(authStatus).toBe(true);
        });
        expect(w.authenticated()).toBe(true);
        expect(w.accessToken()).toBe('authed');
      });
    });
    describe('without providing a callback', function() {
      beforeEach(function() {
        $.mockjax({
          url: 'http://www.example.com',
          responseText: {
            status: 200,
            accessToken: 'authed'
          }
        });
      });
      afterEach(function() {
        $.mockjax.clear();
      });
      it('authStatus should be true', function() {
        w = new IiifAuth('http://www.example.com');
        w.checkStatus();
        expect(w.authenticated()).toBe(true);
        expect(w.accessToken()).toBe('authed');
      });
    });
  });
});
