//= require react
//= require components/embed_footer

// Shortcut to TestUtils addon
var TestUtils = React.addons.TestUtils;

// Create an EmbedFooter element
var footerElement = React.createElement(EmbedFooter,
  {
    toolbarButtons: ['metadata', 'embed_this', 'download'],
    purlUrl: 'http://example.com',
    rosetteUrl: 'http://www.fillmurray.com/20/20'
  }
);

// Render footer element into document
var EmbedFooterElement = TestUtils.renderIntoDocument(footerElement);

// Create a shortcut to rendered EmbedFooter
var renderedEmbedFooter = TestUtils.findRenderedComponentWithType(EmbedFooterElement, EmbedFooter);
describe('EmbedFooter', function() {
  it('Renders an EmbedFooter component', function() {
    expect(renderedEmbedFooter).toBeDefined();
  });

  it('Component has the correct props', function() {
    var props = renderedEmbedFooter.props;
    expect(props.purlUrl).toEqual('http://example.com');
    expect(props.rosetteUrl).toEqual('http://www.fillmurray.com/20/20');
    expect(props.toolbarButtons.length).toEqual(3);
  });

  describe('PURL links', function() {
    it('Renders rosette image tag', function() {
      var props = TestUtils.findRenderedDOMComponentWithTag(renderedEmbedFooter, 'img').props;
      expect(props.className).toEqual('sul-embed-rosette');
      expect(props.src).toEqual('http://www.fillmurray.com/20/20');
    });

    it('Renders purl link without http:// in text', function() {
      var props = TestUtils.findRenderedDOMComponentWithTag(renderedEmbedFooter, 'a').props;
      expect(props.href).toEqual('http://example.com');
      expect(props.target).toEqual('_top');
      expect(props.children).toEqual('example.com');
    });
  });

  describe('Toolbar', function() {
    it('Renders buttons', function() {
      expect(TestUtils.scryRenderedDOMComponentsWithTag(renderedEmbedFooter, 'button').length).toEqual(3);
    });
  });
});
