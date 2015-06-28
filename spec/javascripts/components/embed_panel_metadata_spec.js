//= require react
//= require components/embed_panel_metadata

// Shortcut to TestUtils addon
var TestUtils = React.addons.TestUtils;

// Create an EmbedPanelMetadata element
var embedPanelMdElement = React.createElement(EmbedPanelMetadata,
  {
    copyright: 'Copyright Stanford',
    license: {
      human: 'CC BY-NC Attribution-NonCommercial',
      machine: 'by-nc'
    },
    useAndReproduction: 'You should only use this'
  }
);

// Render component element into document
var embedPanelMdElement = TestUtils.renderIntoDocument(embedPanelMdElement);

// Create a shortcut to rendered MetadataPanel
var renderedEmbedPanelMd = TestUtils.findRenderedComponentWithType(
  embedPanelMdElement, EmbedPanelMetadata);
describe('EmbedMetadataPanel', function() {
  it('Renders a embed panel metadata component', function() {
    expect(renderedEmbedPanelMd).toBeDefined();
  });

  it('Component has the correct props', function() {
    var props = renderedEmbedPanelMd.props;
    expect(props.copyright).toEqual('Copyright Stanford');
    expect(props.license.human).toEqual('CC BY-NC Attribution-NonCommercial');
    expect(props.license.machine).toEqual('by-nc');
    expect(props.useAndReproduction).toEqual('You should only use this');
  });

  describe('Renders html structure', function() {
    it('individuals dt/dd pairs', function() {
      var props = TestUtils.findRenderedDOMComponentWithTag(renderedEmbedPanelMd, 'dl').props;
      expect(props.children.length).toEqual(6);
    });

    it('license span is present', function() {
      var licenseSpan = TestUtils.findRenderedDOMComponentWithClass(
        renderedEmbedPanelMd, 'sul-embed-license-by-nc');
      expect(licenseSpan).toBeDefined();
    })
  });
});
