//= require react
//= require components/embed_header

// Shortcut to TestUtils addon
var TestUtils = React.addons.TestUtils;

// Create an EmbedFooter element
var headerElement = React.createElement(EmbedHeader,
  {
    headerTools: ['EmbedHeaderTitle'],
    title: 'Cool stuff'
  }
);

// Render footer element into document
var EmbedHeaderElement = TestUtils.renderIntoDocument(headerElement);

// Create a shortcut to rendered EmbedHeader
var renderedEmbedHeader = TestUtils.findRenderedComponentWithType(EmbedHeaderElement, EmbedHeader);
describe('EmbedHeader', function() {
  it('Renders an EmbedHeader component', function() {
    expect(renderedEmbedHeader).toBeDefined();
  });

  it('Component has the correct props', function() {
    var props = renderedEmbedHeader.props;
    expect(props.title).toEqual('Cool stuff');
    expect(props.headerTools.length).toEqual(1);
  });

  describe('Renders the headerTools', function() {
    it('Renders title', function() {
      var props = TestUtils.findRenderedDOMComponentWithTag(renderedEmbedHeader, 'span').props;
      expect(props.children).toEqual('Cool stuff');
      expect(props.className).toEqual('sul-embed-header-title');
    });
  });
});
