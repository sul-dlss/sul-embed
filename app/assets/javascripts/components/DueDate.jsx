import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Typography from '@material-ui/core/Typography';

/** */
export default class DueDate extends Component {
  /** */
  static isToday(dueDate) {
    const today = new Date();
    if (today.getDate() === dueDate.getDate()
        && today.getMonth() === dueDate.getMonth()
        && today.getFullYear() === dueDate.getFullYear()) {
      return true;
    }
    return false;
  }

  /** */
  static isTomorrow(dueDate) {
    const tomorrow = new Date(new Date().getTime() + 86400000);
    if (tomorrow.getDate() === dueDate.getDate()
        && tomorrow.getMonth() === dueDate.getMonth()
        && tomorrow.getFullYear() === dueDate.getFullYear()) {
      return true;
    }
    return false;
  }

  /** */
  render() {
    const { className, timestamp } = this.props;

    if (!timestamp) return null;

    const dueDateObject = new Date(timestamp);

    const dueDateDisplay = [];

    if (!DueDate.isToday(dueDateObject)) {
      if (DueDate.isTomorrow(dueDateObject)) {
        dueDateDisplay.push('Tomorrow');
      } else {
        dueDateDisplay.push(dueDateObject.toLocaleDateString(
          'en-US',
          {
            day: 'numeric', month: 'numeric', year: 'numeric',
          },
        ));
      }
    }

    dueDateDisplay.push(dueDateObject.toLocaleTimeString(
      'en-US',
      {
        hour: '2-digit', minute: '2-digit', timeZoneName: 'short',
      },
    ).replace(' PM', ' p.m.').replace(' AM', ' a.m.'));

    return (
      <Typography className={className} variant="body1">
        Due:&nbsp;
        {dueDateDisplay.join(' at ')}
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
