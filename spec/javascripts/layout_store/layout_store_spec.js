/*global LayoutStore, PubSub */

//= require pubsub-js/src/pubsub
//= require modules/layout_store

'use strict';

describe('LayoutStore', function() {
  var layoutStore;
  var storeUpdated;
  var storeSpy;
  beforeEach(function() {
    layoutStore = new LayoutStore({test: 'cool option'});
    storeSpy = jasmine.createSpy('storeSpy');
    storeUpdated = function() {
      storeSpy();
    };
    PubSub.subscribe('LayoutStateUpdated', storeUpdated);
  });
  afterEach(function() {
    PubSub.clearAllSubscriptions();
  });
  describe('on creation', function() {
    it('merges options', function() {
      expect(layoutStore.test).toEqual('cool option');
    });
    it('sets state without publishing layoutStateUpdated', function(done) {
      expect(layoutStore.layoutState).toEqual({
        bottomPanelOpen: true,
        currentImage: null,
        mode: 'single'
      });      
      expect(storeSpy).not.toHaveBeenCalled();
      done();
    });
  });
  describe('currentImageUpdated', function() {
    it('updates state', function(done) {
      PubSub.publishSync('currentImageUpdated', 'best_pic');
      expect(layoutStore.layoutState.currentImage).toEqual('best_pic');
      done();
    });
  });
  describe('bottomPanelOpen', function() {
    it('reverses the state', function(done) {
      PubSub.publishSync('thumbSliderToggle');
      expect(layoutStore.layoutState.bottomPanelOpen).toBe(false);
      done();
    });
  });
});
