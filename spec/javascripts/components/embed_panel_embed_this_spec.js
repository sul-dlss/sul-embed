//= require react
//= require components/embed_panel_embed_this

// Shortcut to TestUtils addon
var TestUtils = React.addons.TestUtils;

// Create an EmbedPanelEmbedThis element
var embedPanelEmbedThisElement = React.createElement(EmbedPanelEmbedThis,
  {
    druid: 'abc123',
    embedIframeUrl: 'http://www.example.com',
    height: 400,
    purlUrl: 'http://purl.stanford.edu',
    title: 'Great object',
    viewerType: 'Embed::Viewer::File',
    width: 500
  }
);

// Render component element into document
var EmbedPanelEmbedThisElement = TestUtils.renderIntoDocument(embedPanelEmbedThisElement);

// Create a shortcut to rendered EmbedPanelEmbedThis
var renderedEmbedPanelEmbedThis = TestUtils.findRenderedComponentWithType(
  EmbedPanelEmbedThisElement, EmbedPanelEmbedThis);
describe('EmbedPanelEmbedThis', function() {
  it('Renders a embed panel embed this component', function() {
    expect(renderedEmbedPanelEmbedThis).toBeDefined();
  });

  it('Component has the correct props', function() {
    var props = renderedEmbedPanelEmbedThis.props;
    expect(props.druid).toEqual('abc123');
    expect(props.embedIframeUrl).toEqual('http://www.example.com');
    expect(props.height).toEqual(400);
    expect(props.purlUrl).toEqual('http://purl.stanford.edu');
    expect(props.viewerType).toEqual('Embed::Viewer::File');
    expect(props.width).toEqual(500);
  });

  describe('Renders html structure', function() {
    it('with formatted object title', function() {
      var objectTitle = TestUtils.findRenderedDOMComponentWithClass(
        EmbedPanelEmbedThisElement, 'sul-embed-embed-title');
      expect(objectTitle.props.children).toEqual(' (Great object)')
    });

    describe('Embed::Viewer::File', function() {
      it('has search label', function() {
        var labels = TestUtils.scryRenderedDOMComponentsWithTag(
          EmbedPanelEmbedThisElement, 'label');
        expect(labels[1].props.htmlFor).toEqual('sul-embed-embed-search')
      });
    });

    describe('Embed::Viewer::Image', function() {
      //pending
      xit('has download section', function() {
      });
    })
  });
});
