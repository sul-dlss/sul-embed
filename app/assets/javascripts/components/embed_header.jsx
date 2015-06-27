var EmbedHeaderTitle = React.createClass({
  propTypes: {
    title: React.PropTypes.string.isRequired
  },
  render: function() {
    return (
      <span className='sul-embed-header-title'>
        {this.props.title}
      </span>
    )
  }
});

var EmbedHeaderFileCount = React.createClass({
  render: function() {
    return (
      <h2 className='sul-embed-item-count' aria-live='polite'></h2>
    )
  }
});

var EmbedHeaderFileSearch = React.createClass({
  render: function() {
    return (
      <div className='sul-embed-search'>
        <label htmlFor='sul-embed-search-input' className='sul-embed-sr-only'>
          Search this list
        </label>
        <input className='sul-embed-search-input' id='sul-embed-search-input' placeholder='Search this list'></input>
      </div>
    )
  }
});

var EmbedHeader = React.createClass({
  propTypes: {
    headerTools: React.PropTypes.array
  },
  render: function() {
    var _this = this;
    return (
      <div className='sul-embed-header'>
        {this.props.headerTools.map(function(tool, i) {
          return React.createElement(window[tool], {key: i, title: _this.props.title});
        })}

      </div>
    )
  }
});
