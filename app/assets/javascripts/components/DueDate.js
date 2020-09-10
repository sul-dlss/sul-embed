import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Typography from '@material-ui/core/Typography';

/** */
export default class DueDate extends Component {
  /** */
  render() {
    const { className, timestamp } = this.props;

    if (!timestamp) return null;

    const dueDateObject = new Date(timestamp);

    return (
      <Typography className={className} variant="body1">
        Due:
        {dueDateObject.toLocaleTimeString(
          'en-US',
          {
            hour: '2-digit', minute: '2-digit', timeZoneName: 'short',
          },
        ).replace(' PM', 'pm').replace(' AM', 'am')}
      </Typography>
    );
  }
}

DueDate.propTypes = {
  className: PropTypes.string,
  timestamp: PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.string,
  ]),
};

DueDate.defaultProps = {
  className: null,
  timestamp: null,
};
