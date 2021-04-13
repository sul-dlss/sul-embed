import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Virtex from './Virtex';
/** */
class ThreeDViewer extends Component {
  /** */
  render3DViewer() {
    const {
      threeDResources,
      windowId,
    } = this.props;

    return (
      <Virtex threeDResource={threeDResources[0]} windowId={windowId} />
    );
  }
  
  /** */
  render() {
    const { TargetComponent, targetProps, threeDResources } = this.props;
    return (
      <TargetComponent {...targetProps}>
        { threeDResources && threeDResources.length > 0 && this.render3DViewer() }
      </TargetComponent>
    )
  }
}

ThreeDViewer.propTypes = {
  TargetComponent: PropTypes.oneOfType([
    PropTypes.func,
    PropTypes.node,
  ]).isRequired,
  targetProps: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  threeDResources: PropTypes.array,
};

ThreeDViewer.defaultProps = {
  threeDResources: [],
};

export default ThreeDViewer;
