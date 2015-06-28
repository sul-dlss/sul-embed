var EmbedPanelDownload = React.createClass({
  propTypes: {
    sizes: React.PropTypes.array.isRequired,
    stacksUrl: React.PropTypes.string.isRequired
  },
  render: function() {
    var _this = this;
    var sizeRows = [];
    var displayNone = {
      display: 'none'
    };
    this.props.sizes.map(function(size) {
      if (size !== 'default') {
        sizeRows.push((
          <tr key={size}>
            <td className={'sul-embed-download-size-type sul-embed-download-' + size}>
              <a className='download-link' href='javascript:;' dangerouslySetInnerHTML={{__html: size + '(<span class="sul-embed-download-dimensions"></span>)'}}></a>
              <span className='sul-embed-stanford-only' style={displayNone}>
                <a href='javascript:;' data-sul-embed-tooltip='false'></a>
              </span>
            </td>
          </tr>
        ))
      } else {
        <tr key={size}>
          <td className={'sul-embed-download-size-type sul-embed-download-' + size}>
            <span dangerouslySetInnerHTML={{__html: size + '(<span class="sul-embed-download-dimensions"></span>)'}}></span>
          </td>
        </tr>
      }
    })

    return (
      <table className='sul-embed-download-options' data-download-sizes={JSON.stringify(this.props.sizes)} data-stacks-url={this.props.stacksUrl}>
        {sizeRows}
      </table>

    );
  }
});
