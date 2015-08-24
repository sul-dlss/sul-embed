/*global ImageXViewer, PubSub, d3 */

//= require jquery
//= require image_x

'use strict';

describe('ImageX Viewer', function() {
  describe('loads and makes available modules', function() {
    it('ImageXViewer is defined', function() {
      expect(ImageXViewer).toBeDefined();
    });

    it('PubSub is defined', function() {
      expect(PubSub).toBeDefined();
    });

    describe('d3', function() {
      it('select is defined', function() {
        expect(d3.select).toBeDefined();
      });
      it('transition is defined', function() {
        expect(d3.transition).toBeDefined();
      });
    });
  });
});
