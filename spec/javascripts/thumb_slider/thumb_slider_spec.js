/*global ThumbSlider */

//= require jquery
//= require modules/thumb_slider

'use strict';

describe('ThumbSlider', function() {
  beforeEach(function() {
    fixture.load('media_viewer.html');
  });
  describe('loads and makes available modules', function() {
    it('ThumbSlider is defined', function() {
      expect(ThumbSlider).toBeDefined();
    });
  });

  describe('init()', function() {
    it('adds a the thumbnail panel to the viewer', function() {
      var selector = '.sul-embed-media .sul-embed-thumb-slider-container';
      expect($(selector).length).toBe(0);
      ThumbSlider.init('.sul-embed-media');
      expect($(selector).length).toBe(1);
    });

    it('hides all media objects except for the first', function() {
      expect($('.sul-embed-media video').css('display')).toBe('inline');
      expect($('.sul-embed-media audio').css('display')).toBe('inline');
      ThumbSlider.init('.sul-embed-media');
      expect($('.sul-embed-media video').css('display')).toBe('inline');
      expect($('.sul-embed-media audio').css('display')).toBe('none');
    });
  });

  describe('addThumbnailsToSlider()', function() {
    it('adds the markup provided to the <ul>', function() {
      var list = '.sul-embed-media .sul-embed-thumb-slider-container ul';
      expect($(list).find('li').length).toBe(0);
      ThumbSlider.init('.sul-embed-media')
                 .addThumbnailsToSlider(['<li>ABC</li>', '<li>XYZ</li>']);
      expect($(list).find('li').length).toBe(2);
    });
  });
});
