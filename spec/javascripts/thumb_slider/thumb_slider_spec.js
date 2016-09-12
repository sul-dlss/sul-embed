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

    it('hides all media objects except for the first (including aria attribute)', function() {
      var videoObject = $('.sul-embed-media [data-slider-object="0"]');
      var audioObject = $('.sul-embed-media [data-slider-object="1"]');

      expect(videoObject).not.toHaveClass('sul-embed-hidden-slider-object');
      expect(audioObject).not.toHaveClass('sul-embed-hidden-slider-object');
      expect(videoObject).not.toHaveAttr('aria-hidden');
      expect(audioObject).not.toHaveAttr('aria-hidden');

      ThumbSlider.init('.sul-embed-media');

      expect(videoObject).not.toHaveClass('sul-embed-hidden-slider-object');
      expect(audioObject).toHaveClass('sul-embed-hidden-slider-object');
      expect(videoObject).not.toHaveAttr('aria-hidden');
      expect(audioObject).toHaveAttr('aria-hidden', 'true');
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
