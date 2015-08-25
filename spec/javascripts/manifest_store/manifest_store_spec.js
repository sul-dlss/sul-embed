/*global ManifestStore, PubSub */

//= require pubsub-js/src/pubsub
//= require modules/manifest_store

'use strict';

describe('ManifestStore', function() {
  var manifestStore;
  var storeUpdated;
  var storeSpy;
  beforeEach(function() {
    manifestStore = new ManifestStore({test: 'cool option'});
    storeSpy = jasmine.createSpy('storeSpy');
    storeUpdated = function() {
      storeSpy();
    };
    PubSub.subscribe('manifestStateUpdated', storeUpdated);
  });
  afterEach(function() {
    PubSub.clearAllSubscriptions();
  });
  describe('on creation', function() {
    it('merges options', function() {
      expect(manifestStore.test).toEqual('cool option');
    });
    it('sets state without publishing manifestStateUpdated', function() {
      expect(manifestStore.manifestState.manifest).toBeNull();
      expect(storeSpy).not.toHaveBeenCalled();
    });
  });
  describe('when manifestDone if fired', function() {
    it('updates state', function(done) {
      PubSub.publishSync('manifestDone', 'hello world');
      expect(manifestStore.manifestState.manifest).toEqual('hello world');
      done();
    });
  });
});
