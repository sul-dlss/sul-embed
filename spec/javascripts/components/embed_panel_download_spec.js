//= require react
//= require components/embed_panel_download

// Shortcut to TestUtils addon
var TestUtils = React.addons.TestUtils;

// Create an EmbedPanelDownload element
var embedPanelDownloadElement = React.createElement(EmbedPanelDownload,
  {
    sizes: ['small', 'medium', 'large', 'xlarge'],
    stacksUrl: 'http://www.example.com'
  }
);

// Render component element into document
var EmbedPanelDownloadElement = TestUtils.renderIntoDocument(embedPanelDownloadElement);

// Create a shortcut to rendered EmbedPanel
var renderedEmbedPanelDownload = TestUtils.findRenderedComponentWithType(
  EmbedPanelDownloadElement, EmbedPanelDownload);
describe('EmbedPanelDownload', function() {
  it('Renders a embed panel download component', function() {
    expect(renderedEmbedPanelDownload).toBeDefined();
  });

  it('Component has the correct props', function() {
    var props = renderedEmbedPanelDownload.props;
    expect(props.sizes).toEqual(['small', 'medium', 'large', 'xlarge']);
    expect(props.stacksUrl).toEqual('http://www.example.com');
  });

  describe('Renders html structure', function() {
    describe('table', function() {
      var table = TestUtils.findRenderedDOMComponentWithTag(
        EmbedPanelDownloadElement, 'table');
      it('is created', function() {
        expect(table).toBeDefined();
      });

      it('has children rows', function() {
        expect(table.props.children.length).toEqual(4);
      });
    });
  });
});
