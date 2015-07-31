/*global ImageXViewer */

//= require modules/image_x_viewer
// require helpers/test_responses/manifest

'use strict';

// Turn off jQuery animation for tests expecting things to be hidden
jQuery.fx.off = true;

describe('ImageX Viewer', function() {
  describe('loads and makes available modules', function() {
    it('ImageXViewer is defined', function() {
      expect(ImageXViewer).toBeDefined();
    });
  });
  describe('init()', function() {
    fixture.preload('image_x_fixture_no_manifest.html',
      'image_x_fixture_bad_manifest.html', 'image_x_fixture.html',
      'manifest.json');
    describe('when missing "data-manifest-url"', function() {
      it('throws an error', function(){
        expect(function() {
          ImageXViewer.init();
        }).toThrowError('Data attribute "data-manifest-url" is missing');
      });
    });
    describe('with a bad "data-manifest-url"', function() {
      beforeEach(function() {
        jasmine.Ajax.install();        
        jasmine.Ajax.stubRequest('http://example.com/bad-url').
          andReturn({status: 404});
      });
      afterEach(function() {
        jasmine.Ajax.uninstall();
      });
      it('throws an error', function(done){
        fixture.load('image_x_fixture_bad_manifest.html');
        expect(function() {
          ImageXViewer.init();
          done();
        }).toThrowError('Could not access manifest.json');
      });
    });
    describe('with required data attributes', function(){
      beforeEach(function() {
        jasmine.Ajax.install();
        jasmine.Ajax.stubRequest('http://example.com/good-url/manifest.json').
          andReturn(
            {
              status: 200,
              responseText: JSON.stringify(fixture.load('manifest.json')[0])
            }
        );
      });
      afterEach(function() {
        jasmine.Ajax.uninstall();
      });
      it('initializes without error', function() {
        fixture.load('image_x_fixture.html');
        expect(function() {
          ImageXViewer.init();
        }).not.toThrowError();
      });
    });
    describe('should setup thumbslider', function() {
      beforeEach(function(done) {
        fixture.cleanup();
        jasmine.Ajax.install();
        jasmine.Ajax.stubRequest('http://example.com/good-url/manifest.json')
          .andReturn(
            {
              status: 200,
              responseText: JSON.stringify(fixture.load('manifest.json')[0])
            }
        );
        done();
      });
      afterEach(function() {
        jasmine.Ajax.uninstall();
      });
      it('call generates <li>', function(done) {
        fixture.load('image_x_fixture.html');
        setTimeout(function () {
          ImageXViewer.init();
          var $thumbslider = $('.sul-embed-image-x-thumb-slider');
          expect($thumbslider.length).toEqual(1);
          expect($thumbslider.find('li.sul-embed-image-x-thumb').length)
            .toEqual(36);
          done();
        }, 0);
      });
      it('only loads images that are visible', function(done) {
        fixture.load('image_x_fixture.html');
        setTimeout(function () {
          ImageXViewer.init();
          var $thumbslider = $('.sul-embed-image-x-thumb-slider');
          expect($thumbslider.find('img[data-src*="stacks"]').length)
            .toEqual(36);
          expect($thumbslider.find('img[src*="stacks"]').length)
            .toBeLessThan(36);
          done();
        }, 0);
      });
      it('adds thumb slider open/close actions', function(done) {
        fixture.load('image_x_fixture.html');
        setTimeout(function () {
          ImageXViewer.init();
          var $thumbslider = $('.sul-embed-image-x-thumb-slider');
          var openClose = $('.sul-embed-image-x-thumb-slider-open-close');
          expect(openClose.length).toEqual(1);
          expect(openClose).not.toBeHidden();
          expect($thumbslider.find('img')).not.toBeHidden();
          openClose.click();
          expect(openClose).not.toBeHidden();
          expect($thumbslider).toBeHidden();
          done();
        }, 0);
      });
    });
  });
});
