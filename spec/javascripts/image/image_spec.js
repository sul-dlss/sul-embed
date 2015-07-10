//= require jquery
//= require image

describe('Image viewer', function() {
  describe('loads and makes available modules', function() {
    it('jQuery is defined', function() {
      expect(jQuery).toBeDefined();
    });

    it('OpenSeadragon is defined', function() {
      expect(OpenSeadragon).toBeDefined();
    });

    it('CssInjection is defined', function() {
      expect(CssInjection).toBeDefined();
    });

    it('sulEmbedDownloadPanel is defined', function() {
      expect(sulEmbedDownloadPanel).toBeDefined();
    });

    it('tooltip is defined', function() {
      expect($('').tooltip).toBeDefined();
    });

    it('jQueryiiifViewer is defined', function() {
      expect($('').iiifOsdViewer).toBeDefined();
    });

    it('CommonViewerBehavior is defined', function() {
      expect(CommonViewerBehavior).toBeDefined();
    });

    it('PopupPanels is defined', function() {
      expect(PopupPanels).toBeDefined();
    });

    it('EmbedThis is defined', function() {
      expect(EmbedThis).toBeDefined();
    });
  });
});
