var EmbedPanelEmbedThis = React.createClass({
  propTypes: {
    druid: React.PropTypes.string.isRequired,
    embedIframeUrl: React.PropTypes.string.isRequired,
    height: React.PropTypes.oneOfType([
      React.PropTypes.number,
      React.PropTypes.string
      ]).isRequired,
    purlUrl: React.PropTypes.string.isRequired,
    viewerType: React.PropTypes.string.isRequired,
    title: React.PropTypes.string.isRequired,
    width: React.PropTypes.oneOfType([
      React.PropTypes.number,
      React.PropTypes.string
      ]).isRequired
  },
  render: function() {
    var _this = this;
    var panelElements = [];
    var embedCodeDefault = '<iframe src="' + _this.props.embedIframeUrl + '?url=' + _this.props.purlUrl + '/' + _this.props.druid + '" height="' + _this.props.height + 'px" width="' + _this.props.width + 'px" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" allowfullscreen></iframe>';

    if (this.props.viewerType === 'Embed::Viewer::File') {
      panelElements.push((
        <div key='fileBehavior' className='sul-embed-section'>
          <input type='checkbox' id='sul-embed-embed-search' data-embed-attr='hide_search' defaultChecked='true'></input>
          <label htmlFor='sul-embed-embed-search'>
            add search box
          </label>
          <label htmlFor='sul-embed-min_files_to_search'>
            {' for'}
            <input type='text' id='sul-embed-min_files_to_search' data-embed-attr='min_files_to_search' defaultValue='10'></input>
            or more files
          </label>
        </div>
      ));
    }

    if (this.props.viewerType === 'Embed::Viewer::Image') {
      panelElements.push((
        <div key='imageBehavior' className='sul-embed-section'>
          <input type='checkbox' id='sul-embed-embed-download' data-embed-attr='hide_download' defaultChecked='true'></input>
          <label htmlFor='sul-embed-embed-download'>
            download
          </label>
        </div>
      ));
    }

    return (
      <div className='sul-embed-panel-body'>
        <div className='sul-embed-embed-this-form'>
          <span className='sul-embed-options-label'>
            Select options:
          </span>
          <div className='sul-embed-section sul-embed-embed-title-section'>
            <input type='checkbox' id='sul-embed-embed-title' data-embed-attr='hide_title' defaultChecked='true'></input>
            <label htmlFor='sul-embed-embed-title'>
              title
              <span className='sul-embed-embed-title'>
                 {' (' + _this.props.title + ')'}
              </span>
            </label>
          </div>
          {panelElements}
          <div className='sul-embed-section'>
            <input type='checkbox' id='sul-embed-embed' data-embed-attr='hide_embed' defaultChecked='true'></input>
            <label htmlFor='sul-embed-embed'>
              embed
            </label>
          </div>
          <div>
            <div className='sul-embed-options-label'>
              <label htmlFor='sul-embed-iframe-code'>
                Embed code:
              </label>
            </div>
            <div className='sul-embed-section'>
              <textarea id='sul-embed-iframe-code' data-behavior='iframe-code' rows='4' defaultValue={embedCodeDefault}>
              </textarea>
            </div>
          </div>
        </div>
      </div>
    );
  }
});
