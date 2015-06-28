var EmbedPanelMetadata = React.createClass({
  propTypes: {
    copyright: React.PropTypes.string,
    license: React.PropTypes.shape({
      human: React.PropTypes.string,
      machine: React.PropTypes.string
    }),
    useAndReproduction: React.PropTypes.string
  },
  render: function() {
    var panelElements = [];
    if (this.props.useAndReproduction) {
      panelElements.push((<dt key='useTerm'>Use and reproduction</dt>), (<dd key='useDesc'>{this.props.useAndReproduction}</dd>));
    }

    if (this.props.copyright) {
      panelElements.push((<dt key='copyTerm'>Copyright</dt>), (<dd key='copyDesc'>{this.props.copyright}</dd>));
    }

    if (this.props.license) {
      panelElements.push((<dt key='licTerm'>License</dt>), (
        <dd key='licDesc'>
          <span className={'sul-embed-license-' + this.props.license.machine}></span>
          {this.props.license.human}
        </dd>
      ));
    }

    return (
      <div className='sul-embed-panel-body'>
        <dl>
          {panelElements}
        </dl>
      </div>
    );
  }
});
