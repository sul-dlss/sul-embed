/*global ImageXViewer, PubSub */

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
  });
});
