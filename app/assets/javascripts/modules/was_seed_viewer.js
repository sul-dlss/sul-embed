/*global Sly */

(function( global ) {
  'use strict';
  var Module = (function() {

    return {
      init: function() {
        $('li.sul-embed-was-thumb-item').each(function() {

          // Set all list item widths to their height (making a square)
          // so that Sly can calculate the container's width appropriately
          $(this).width($(this).height());
        });

        var $wasThumbFrame = $('.sul-embed-was-seed');
        var dataAttributes = $wasThumbFrame.data();

        // Create the SLY scroll div on fly
        var $wasThumbScroll = $('<div class="sul-embed-thumb-slider-scroll"><div class="sul-embed-thumb-slider-handle"/></div>');
        $wasThumbScroll.insertAfter($wasThumbFrame);

        var thumbSliderSly = new Sly($wasThumbFrame, {
          horizontal: 1,
          itemNav: 'forceCentered',
          smart: 1,
          activateMiddle: 1,
          activateOn: 'click',
          mouseDragging: 1,
          touchDragging: 1,
          releaseSwing: 1,
          scrollBar: $wasThumbScroll,
          dragHandle: 1,
          dynamicHandle: 1,
          startAt: dataAttributes.sulThumbsListCount-2, //The focus should be on one before the last thumb
          speed: 300,
          elasticBounds: 1,
          scrollSource: $wasThumbFrame,
          scrollBy: 1,
          scrollTrap: true,
          scrollHijack: 100
        }).init();
      }
    };
  })();

  global.WasSeedViewer = Module;
})(this);
