var EmbedFooterButton = React.createClass({
  propTypes: {
    buttonType: React.PropTypes.string.isRequired
  },
  render: function() {
    var button;
    switch (this.props.buttonType) {
      case 'metadata':
        button = <EmbedFooterMetadataButton />;
        break;
      case 'embed_this':
        button = <EmbedFooterEmbedThisButton />;
        break;
      case 'download':
        button = <EmbedFooterDownloadButton />;
        break;
    }
    return button;
  }
});

var EmbedFooterMetadataButton = React.createClass({
  render: function() {
    return (
      <button className='sul-embed-footer-tool sul-embed-btn sul-embed-btn-xs sul-embed-btn-default fa fa-info-circle' aria-expanded='false' data-sul-embed-toggle = 'sul-embed-metadata-panel'>
      </button>
    );
  }
});

var EmbedFooterEmbedThisButton = React.createClass({
  render: function() {
    return (
      <button className='sul-embed-footer-tool sul-embed-btn sul-embed-btn-xs sul-embed-btn-default fa fa-code' aria-expanded='false' data-sul-embed-toggle = 'sul-embed-embed-this-panel'>
      </button>
    );
  }
});

var EmbedFooterDownloadButton = React.createClass({
  render: function() {
    return (
      <button className='sul-embed-footer-tool sul-embed-btn sul-embed-btn-xs sul-embed-btn-default fa fa-download' aria-expanded='false' data-sul-embed-toggle = 'sul-embed-download-panel'>
      </button>
    );
  }
});

var EmbedFooterToolbar = React.createClass({
  propTypes: {
    toolbarButtons: React.PropTypes.array.isRequired
  },
  render: function() {
    return (
      <div className='sul-embed-footer-toolbar'>
        {this.props.toolbarButtons.map(function(button) {
          return <EmbedFooterButton key={button} buttonType={button}/>
        })}

      </div>
    );
  }
});

var EmbedFooterPurl = React.createClass({
  propTypes: {
    purlUrl: React.PropTypes.string.isRequired,
    rosetteUrl: React.PropTypes.string.isRequired
  },
  render: function() {
    return (
      <div className='sul-embed-purl-link'>
        <img src={this.props.rosetteUrl} className='sul-embed-rosette'></img>
        <a href={this.props.purlUrl} target='_top'>
          {this.props.purlUrl.replace('http://', '')}
        </a>
      </div>
    );
  }
});

// Main Embed Footer component
var EmbedFooter = React.createClass({
  propTypes: {
    toolbarButtons: React.PropTypes.array.isRequired,
    purlUrl: React.PropTypes.string.isRequired,
    rosetteUrl: React.PropTypes.string.isRequired
  },
  render: function() {
    return (
      <div className='sul-embed-footer'>
        <EmbedFooterToolbar toolbarButtons = {this.props.toolbarButtons} />
        <EmbedFooterPurl purlUrl = {this.props.purlUrl} rosetteUrl = {this.props.rosetteUrl} />
      </div>
    );
  }
});
