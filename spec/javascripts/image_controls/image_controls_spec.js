/*global ImageControls */
//= require modules/image_controls

'use strict';

describe('ImageControls', function() {
  var imageControls;

  beforeEach(function() {
    fixture.load('image_controls.html');
    imageControls = ImageControls.init($('.sul-embed-image-x-buttons'));

  });
  describe('init', function() {
  });
  describe('render', function() {
    describe('paged button', function(){
      it('is visible when turned on', function() {
        imageControls.render({paged: true});
        expect(imageControls._paged()).not.toHaveClass('sul-embed-hidden');
      });
      it('is active when canvas viewingMode is paged', function() {
        imageControls.render({}, {viewingMode: 'paged'});
        expect(imageControls._paged()).toHaveClass('active');
      });
    });
    describe('individuals button', function() {
      it('is visible when turned on', function() {
        imageControls.render({individuals: true});
        expect(imageControls._individuals()).not
          .toHaveClass('sul-embed-hidden');
      });
      it('is active when canvas viewingMode is individuals', function() {
        imageControls.render({}, {viewingMode: 'individuals'});
        expect(imageControls._individuals()).toHaveClass('active');
      });
    });
    describe('overview button', function() {
      it('is visible when turned on', function() {
        imageControls.render({overviewPerspectiveAvailable: true});
        expect(imageControls._overview()).not.toHaveClass('sul-embed-hidden');
      });
      it('is active when canvas perspective is overview', function() {
        imageControls.render({}, {perspective: 'overview'});
        expect(imageControls._overview()).toHaveClass('active');
      });
      it('other controls are not active', function() {
        //paged
        imageControls._paged().addClass('active');
        expect(imageControls._paged()).toHaveClass('active');
        imageControls.render({}, {perspective: 'overview'});
        expect(imageControls._paged()).not.toHaveClass('active');
        //individuals
        imageControls._individuals().addClass('active');
        expect(imageControls._individuals()).toHaveClass('active');
        imageControls.render({}, {perspective: 'overview'});
        expect(imageControls._individuals()).not.toHaveClass('active');
      });
    });
    describe('fullscreen button', function(){
      it('when enabled', function() {
        imageControls.render({fullscreen: true});
        expect(imageControls._fullscreen()).not.toBeDisabled();
      });
      it('when disabled', function() {
        imageControls.render({fullscreen: false});
        expect(imageControls._fullscreen()).toBeDisabled();
      });
    });
  });
});
