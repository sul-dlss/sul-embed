import React, { Component } from 'react';
import { withStyles } from '@material-ui/core/styles';

class CdlCountdown extends Component {
  /** */
  count() {
    const { remainingSeconds } = this.props;
    let count = remainingSeconds;
    if (remainingSeconds > 60) {
      count = Math.floor(remainingSeconds / 60);
    }
    return new Number(count).toLocaleString();
  }

  /** */
  units() {
    const { remainingSeconds } = this.props;
    if (remainingSeconds > 60) {
      return 'minutes'
    }
    return 'seconds';
  }

  render() {
    const { classes } = this.props;
    return (
      <span className={classes.countdown}>
        {this.count()} {this.units()} remaining
      </span>
    );
  }
}

const styles = (theme) => ({
  countdown: {
    color: theme.palette.primary.main,
    marginLeft: theme.spacing(5)
  },
})

export default withStyles(styles)(CdlCountdown)
