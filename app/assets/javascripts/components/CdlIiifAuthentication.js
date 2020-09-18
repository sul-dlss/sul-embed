import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
// import WindowAuthenticationBar from 'mirador/dist/es/src/containers/WindowAuthenticationBar';

/** */
class CdlIiifAuthentication extends Component {
  /** */
  render() {
    console.log(this.props);
    const {
      confirm, description, handleAuthInteraction, header, isInteractive, label,
      authServiceId, windowId, status,
    } = this.props.targetProps;

    TargetComponent.prototype.renderLogin = (stuff) => {

      return (
        <WindowAuthenticationBar
          description={description}
          label={label}
          confirmButton={confirm}
          onConfirm={() => handleAuthInteraction(windowId, authServiceId)}
          {...{
            authServiceId,
            status,
            windowId,
          }}
        />
      );
    };
    return (
      <this.props.TargetComponent {...this.props.targetProps} />
    )
  }
}

/** */
const styles = (theme) => ({
  
});

const CdlIiifAuthenticationPlugin = {
};

export default withStyles(styles)(CdlIiifAuthentication);
export { CdlIiifAuthenticationPlugin };
