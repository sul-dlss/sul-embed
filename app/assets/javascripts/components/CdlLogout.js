import React, { Component } from 'react';
import { withStyles } from '@material-ui/core/styles';
import Paper from '@material-ui/core/Paper';
import Button from '@material-ui/core/Button';
import TimerIcon from '@material-ui/icons/TimerSharp';
import WarningIcon from '@material-ui/icons/WarningSharp';
import Typography from '@material-ui/core/Typography';
import {
  getWindow,
} from 'mirador/dist/es/src/state/selectors';
import CdlCountdown from './CdlCountdown';
import DueDate from './DueDate';
import { AuthenticationSender } from 'mirador/dist/es/src/components/AuthenticationSender';

class CdlLogout extends Component {
  /** */
  constructor(props) {
    super(props);

    this.timer = null;
    this.state = { renew: false };
    this.handleLogout = this.handleLogout.bind(this);
    this.handleRenew = this.handleRenew.bind(this);
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

  /** */
  handleRenew() {
    this.setState({ renew: true });
  }

  /** */
  authenticationInteraction() {
    const { handleInteraction, loginUrl } = this.props;

    this.setState({ renew: false });
    handleInteraction(loginUrl);
  }

  render() {
    const { authenticationUrl, classes, dueDate, items, label, targetProps, waitlist, TargetComponent } = this.props;
    const { renew } = this.state;
    const dueDateObject = new Date(dueDate * 1000);
    const remainingSeconds = Math.floor((dueDateObject - Date.now()) / 1000);

    const fifteenMinutes = 60 * 15;
    const fiveMinutes = 60 * 5;

    const canRenew = authenticationUrl && (waitlist <= items) && (remainingSeconds >= 0 && remainingSeconds < fifteenMinutes);

    const renewWarningClass = remainingSeconds < fifteenMinutes ? classes.renewWarning : null;

    return (
      <Paper square elevation={4} classes={{ root: [classes.paper, renewWarningClass].join(' ') }}>
        <AuthenticationSender url={renew && authenticationUrl} handleInteraction={this.authenticationInteraction} />
        <div className={classes.topBar}>
          <div className={classes.dueInformation}>
            <TimerIcon className={classes.icon} />
            <DueDate timestamp={dueDate * 1000}/>
          </div>
          <Button variant="outlined" onClick={this.handleLogout} className={classes.button}>
            {label}
          </Button>
          {canRenew && <Button variant="outlined" onClick={this.handleRenew} className={classes.button}>
                                  Renew
                                </Button>
          }
          { (waitlist > items) && <Typography className={classes.waitlist}><WarningIcon className={classes.warningIcon}/> Waitlist started, no renewals</Typography>}
          { remainingSeconds >= 0 && remainingSeconds < fifteenMinutes && (
            <CdlCountdown remainingSeconds={remainingSeconds} />) }
        </div>
      </Paper>
    )
  }
}

const styles = (theme) => ({
  button: {
    backgroundColor: theme.palette.background.paper,
    marginLeft: theme.spacing(5),
  },
  dueInformation: {
    display: 'inline-flex',
  },
  icon: {
    marginRight: theme.spacing(2),
  },
  paper: {
  },
  renewWarning: {
    backgroundColor: '#F9F6EF',
  },
  topBar: {
    alignItems: 'center',
    display: 'flex',
    paddingBottom: theme.spacing(1),
    paddingLeft: theme.spacing(1),
    paddingRight: theme.spacing(1),
    paddingTop: theme.spacing(1),
  },
  waitlist: {
    alignItems: 'center',
    display: 'inline-flex',
    color: theme.palette.primary.main,
    marginLeft: theme.spacing(5)
  },
  warningIcon: {
    color: theme.palette.notification.main,
  },
})

const mapStateToProps = (state, { windowId} ) => {
  const canvasId = (getCurrentCanvas(state, { windowId }) || {}).id;
  const service = selectCanvasAuthService(state, { canvasId, windowId });
  const endpoint = service && service.getService('http://iiif.io/api/auth/1/renew');

  const window = getWindow(state, { windowId });

  const payload = window.cdlInfoResponse && window.cdlInfoResponse.payload;
  return {
    authenticationUrl: endpoint && endpoint.id,
    dueDate: payload && payload.exp,
    items: window && window.cdlAvailability && window.cdlAvailability.items,
    loginUrl: service && service.id,
    waitlist: window && window.cdlAvailability && window.cdlAvailability.waitlist,
  }
}

const CdlLogoutPlugin = {
  mapStateToProps,
}

export default withStyles(styles)(CdlLogout);
export { CdlLogoutPlugin };
