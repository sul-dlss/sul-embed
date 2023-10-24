import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';

/** */
class CdlCountdown extends Component {
  /** */
  count() {
    const { remainingSeconds } = this.props;
    let count = remainingSeconds;
    if (remainingSeconds > 60) {
      count = Math.ceil(remainingSeconds / 60);
    }
    return Number(count).toLocaleString();
  }

  /** */
  units() {
    const { remainingSeconds } = this.props;
    if (remainingSeconds > 60) {
      return 'minutes';
    }
    if (remainingSeconds === 1) {
      return 'second';
    }
    return 'seconds';
  }

  /** */
  render() {
    const { classes } = this.props;
    return (
      <span className={classes.countdown}>
        {[this.count(), this.units(), 'remaining'].join(' ')}
      </span>
    );
  }
}

/** */
const styles = (theme) => ({
  countdown: {
    color: theme.palette.primary.main,
    marginLeft: theme.spacing(5),
  },
});

CdlCountdown.propTypes = {
  classes: PropTypes.objectOf(PropTypes.string).isRequired,
  remainingSeconds: PropTypes.number.isRequired,
};

export default withStyles(styles)(CdlCountdown);
