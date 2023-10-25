const CommonViewerBehavior = require('../../../app/javascript/src/modules/common_viewer_behavior.js');

let fakeFunction;
describe('Common Viewer Behavior', () => {
  describe('initializeViewer', () => {
    document.body.innerHTML = '<div id="sul-embed-object"></div>';
    beforeEach(() => {
      fakeFunction = jest.fn();
    });
    describe('with callback function', () => {
      test('should initialize and call passed in function', () => {
        CommonViewerBehavior.initializeViewer(fakeFunction);
        expect(fakeFunction).toHaveBeenCalled();
      });
    });

    describe('without callback function', () => {
      test('should initialize', () => {
        CommonViewerBehavior.initializeViewer();
        expect(fakeFunction).not.toHaveBeenCalled();
      });
    });
  });
});
