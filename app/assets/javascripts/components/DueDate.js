import React, { Component } from 'react';
import Typography from '@material-ui/core/Typography';

export default class DueDate extends Component {
  render() {
    const { className, timestamp } = this.props;

    if (!timestamp) return null;

    const dueDateObject = new Date(timestamp);

    return (
      <Typography className={className} variant="body1">
        Due: {dueDateObject.toLocaleTimeString(
          'en-US',
          { timeZone: 'America/Los_Angeles', timeZoneName: 'short', hour: '2-digit', minute: '2-digit' }
        ).replace(' PM', 'pm').replace(' AM', 'am')}
      </Typography>
    );
  }
}
