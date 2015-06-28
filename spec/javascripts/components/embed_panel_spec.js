//= require react
//= require components/embed_panel

// Shortcut to TestUtils addon
var TestUtils = React.addons.TestUtils;

// A fake embed component
var FakeComponent = React.createClass({
  render: function() {
    return React.createElement('div', null, 'Fake Component');
  }
});

// Create an EmbedPanel element
var embedPanelElement = React.createElement(EmbedPanel,
  {
    panelTitle: 'Cool stuff <span>yolo</span>',
    panelClass: 'sul-embed-test-class',
    panelType: 'FakeComponent'
  }
);

// Render component element into document
var EmbedPanelElement = TestUtils.renderIntoDocument(embedPanelElement);

// Create a shortcut to rendered EmbedPanel
var renderedEmbedPanel = TestUtils.findRenderedComponentWithType(
  EmbedPanelElement, EmbedPanel);
describe('EmbedPanel', function() {
  it('Renders a embed panel component', function() {
    expect(renderedEmbedPanel).toBeDefined();
  });

  it('Component has the correct props', function() {
    var props = renderedEmbedPanel.props;
    expect(props.panelTitle).toEqual('Cool stuff <span>yolo</span>');
    expect(props.panelClass).toEqual('sul-embed-test-class');
    expect(props.panelType).toEqual('FakeComponent');
  });

  describe('Renders html structure', function() {
    it('with custom classes', function() {
      var fakeClassElements = TestUtils.findRenderedDOMComponentWithClass(
        EmbedPanelElement, 'sul-embed-test-class');
      expect(fakeClassElements.props.children.length).toEqual(2);
    });

    it('with panel title', function() {
      var panelTitle = TestUtils.findRenderedDOMComponentWithClass(
        EmbedPanelElement, 'sul-embed-panel-title');
      expect(panelTitle.props.dangerouslySetInnerHTML.__html).toEqual('Cool stuff <span>yolo</span>')
    });

    it('with panel component', function() {
      var panelComponent = TestUtils.findRenderedComponentWithType(
        EmbedPanelElement, FakeComponent);
      expect(panelComponent).toBeDefined();
    });
  });
});
