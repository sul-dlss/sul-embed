//= require jquery
//= require file

describe('File viewer', function() {
  describe('loads and makes available modules', function() {
    it('React is defined', function() {
      expect(React).toBeDefined();
    });

    it('ReactRailsUJS is defined', function() {
      expect(ReactRailsUJS).toBeDefined();
    });

    it('jQuery is defined', function() {
      expect(jQuery).toBeDefined();
    });

    it('CssInjection is defined', function() {
      expect(CssInjection).toBeDefined();
    });

    it('List is defined', function() {
      expect(List).toBeDefined();
    });

    it('tooltip is defined', function() {
      expect($('').tooltip).toBeDefined();
    });

    it('FileSearch is defined', function() {
      expect(FileSearch).toBeDefined();
    });

    it('CommonViewerBehavior is defined', function() {
      expect(CommonViewerBehavior).toBeDefined();
    });

    it('FilePreview is defined', function() {
      expect(FilePreview).toBeDefined();
    });

    it('PopupPanels is defined', function() {
      expect(PopupPanels).toBeDefined();
    });

    it('EmbedThis is defined', function() {
      expect(EmbedThis).toBeDefined();
    });
  });

  describe('React components are available', function() {
    it('EmbedFooter', function() {
      expect(EmbedFooter).toBeDefined();
    });
  });
});
