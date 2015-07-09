//= require jquery
//= require modules/common_viewer_behavior

'use strict';

describe('Common Viewer Behavior', function() {
  describe('initializeViewer', function() {
    fixture.set('<div id="sul-embed-object"></div>');
    var testObject;
    beforeEach(function(done) {
      testObject = {
        fakeFunction: function() {}
      };
      spyOn(testObject, 'fakeFunction');
      done();      
    });
    describe('with callback function', function() {
      
      it('should initialize and call passed in function', function(done) {
        CommonViewerBehavior.initializeViewer(testObject.fakeFunction);
        expect(testObject.fakeFunction).toHaveBeenCalled();
        done();
      });
    });
    
    describe('without callback function', function() {
      it('should initialize', function(done) {
        CommonViewerBehavior.initializeViewer();
        expect(testObject.fakeFunction).not.toHaveBeenCalled();
        done();
      });
    });
  });
});
