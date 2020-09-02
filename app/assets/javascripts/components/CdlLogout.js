import React, { Component } from 'react';
import { withStyles } from '@material-ui/core/styles';
import Paper from '@material-ui/core/Paper';
import Button from '@material-ui/core/Button';
import TimerIcon from '@material-ui/icons/Timer';
import {
  getWindow,
} from 'mirador/dist/es/src/state/selectors';
import CdlCountdown from './CdlCountdown';


class CdlLogout extends Component {
  /** */
  constructor(props) {
    super(props);

    this.timer = null;
    this.handleLogout = this.handleLogout.bind(this);
  }

  componentDidMount() {
    this.timer = setInterval(() => this.forceUpdate(), 1000 * 15);
  }

  componentWillUnmount() {
    clearInterval(this.timer);
  }

  /** */
  handleLogout() {
    const {
      authServiceId, depWindow, logoutServiceId, resetAuthenticationState,
    } = this.props;
    (depWindow || window).open(logoutServiceId);

    resetAuthenticationState({ authServiceId });
  }

  render() {
    const { classes, dueDate, label, targetProps, TargetComponent } = this.props;
    const dueDateObject = new Date(dueDate * 1000);
    const remainingSeconds = Math.floor((dueDateObject - Date.now()) / 1000);

    const fifteenMinutes = 60 * 15;

    const renewWarningClass = remainingSeconds < fifteenMinutes ? classes.renewWarning : null;

    return (
      <Paper square elevation={4} classes={{ root: [classes.paper, renewWarningClass].join(' ') }}>
        <div className={classes.topBar}>
          <div className={classes.dueInformation}>
            <TimerIcon />
            Due at {dueDateObject.toLocaleTimeString('en-US', { timeZone: 'America/Los_Angeles' })} PT

            { remainingSeconds >= 0 && remainingSeconds < fifteenMinutes && (
              <CdlCountdown remainingSeconds={remainingSeconds} />) }
          </div>
          <Button variant="outlined" onClick={this.handleLogout} className={classes.checkIn}>
            {label}
          </Button>
        </div>
      </Paper>
    )
  }
}

const styles = (theme) => ({
  checkIn: {
    backgroundColor: theme.palette.background.paper,
  },
  dueInformation: {
    alignItems: 'center',
    display: 'inline-flex',
  },
  paper: {
  },
  renewWarning: {
    backgroundColor: '#F9F6EF',
  },
  topBar: {
    display: 'flex',
    justifyContent: 'space-between',
    paddingBottom: theme.spacing(1),
    paddingLeft: theme.spacing(1),
    paddingRight: theme.spacing(1),
    paddingTop: theme.spacing(1),
  }
})

const mapStateToProps = (state, { windowId} ) => {
  const window = getWindow(state, { windowId });
  const payload = window.cdlInfoResponse && window.cdlInfoResponse.payload;
  return {
    dueDate: payload && payload.exp,
  }
}

const CdlLogoutPlugin = {
  mapStateToProps,
}

export default withStyles(styles)(CdlLogout);
export { CdlLogoutPlugin };
