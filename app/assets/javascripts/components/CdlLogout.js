import React, { Component } from 'react';
import { withStyles } from '@material-ui/core/styles';
import Paper from '@material-ui/core/Paper';
import TimerIcon from '@material-ui/icons/Timer';
import {
  getWindow,
} from 'mirador/dist/es/src/state/selectors';


class CdlLogout extends Component {
  render() {
    const { classes, dueDate, targetProps, TargetComponent } = this.props;
    return (
      <Paper square elevation={4} classes={{ root: classes.paper }}>
        <div className={classes.topBar}>
          <TimerIcon />
          Due at {dueDate}
          <TargetComponent {...this.props} />
        </div>
      </Paper>
    )
  }
}

const styles = () => ({
  paper: {
  },
  topBar: {
    alignItems: 'center',
  }
})

const mapStateToProps = (state, { windowId} ) => {
  const window = getWindow(state, { windowId });
  const payload = window.cdlInfoResponse && window.cdlInfoResponse.payload;
  return {
    dueDate: payload && new Date(payload.exp * 1000).toLocaleTimeString('en-US', { timeZone: 'America/Los_Angeles' }),
  }
}

const CdlLogoutPlugin = {
  mapStateToProps,
}

export default withStyles(styles)(CdlLogout);
export { CdlLogoutPlugin };
