import React, { Component } from 'react';
import PropTypes from 'prop-types';

/**
 * CdlLoginWindowSizing ~ Wrap the Mirador component that provides a NewWindow compontent
 *                        to pass inject our own features prop to handle window sizing
*/
class CdlLoginWindowSizing extends Component {
  /** */
  render() {
    const { TargetComponent } = this.props;

    const width = 600;
    const height = 500;
    const top = 100;
    const left = (window.innerWidth / 2) - (width / 2);

    const features = `width=${width},height=${height},top=${top},left=${left > 0 ? left : 0}`;

    return <TargetComponent features={features} {...this.props} />;
  }
}

CdlLoginWindowSizing.propTypes = {
  TargetComponent: PropTypes.oneOfType([
    PropTypes.func,
    PropTypes.node,
  ]).isRequired,
};

export default CdlLoginWindowSizing;
