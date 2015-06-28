var EmbedPanel = React.createClass({
  propTypes: {
    // TODO: Move panelClass from string to element when everything is in React
    panelClass: React.PropTypes.string.isRequired,
    panelTitle: React.PropTypes.string.isRequired,
    panelType: React.PropTypes.string.isRequired
  },
  render: function() {
    var _this = this;
    var panelStyles = {
      display: 'none'
    };
    var panelContent = React.createElement(window[this.props.panelType], this.props);
    return (
      <div className='sul-embed-panel-container'>
        <div className={'sul-embed-panel ' + _this.props.panelClass} style={panelStyles} aria-hidden='true'>
          <div className='sul-embed-panel-header'>
            <button className='sul-embed-close' data-sul-embed-toggle={_this.props.panelClass}>
              <span aria-hidden='true' className='fa fa-close'></span>
              <span className='sul-embed-sr-only'>Close</span>
            </button>
            <div className='sul-embed-panel-title' dangerouslySetInnerHTML={{__html: this.props.panelTitle}}>
            </div>
          </div>
          {panelContent}
        </div>
      </div>
    )
  }
});
