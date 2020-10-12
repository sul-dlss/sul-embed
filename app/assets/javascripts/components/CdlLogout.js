import React, { Component } from 'react';
import { withStyles } from '@material-ui/core/styles';
import Button from '@material-ui/core/Button';
import WarningIcon from '@material-ui/icons/WarningSharp';
import Typography from '@material-ui/core/Typography';
import { NewWindow } from 'mirador/dist/es/src/components/NewWindow';
import CdlCountdown from './CdlCountdown';

/** */
class CdlLogout extends Component {
  /** */
  constructor(props) {
    super(props);

    this.state = { renew: false };
    this.handleRenew = this.handleRenew.bind(this);
    this.onRenewed = this.onRenewed.bind(this);
  }

  /** */
  onRenewed() {
    const { authServiceId, accessTokenServiceId, requestAccessToken } = this.props;
    requestAccessToken(accessTokenServiceId, authServiceId);
    this.setState({ renew: false });
  }

  /** */
  handleRenew() {
    this.setState({ renew: true });
  }

  /** */
  render() {
    const {
      classes, dueDate, items, label, renewServiceId, targetProps, waitlist, TargetComponent,
    } = this.props;
    const { renew } = this.state;
    const dueDateObject = new Date(dueDate * 1000);
    const remainingSeconds = Math.floor((dueDateObject - Date.now()) / 1000);

    const fifteenMinutes = 60 * 15;
    const fiveMinutes = 60 * 5;

    const canRenew = renewServiceId && (waitlist <= items) && (remainingSeconds >= 0 && remainingSeconds < fiveMinutes);

    if (renew) {
      return (
        <NewWindow name="IiifLoginSender" url={`${renewServiceId}?origin=${window.origin}`} features="centerscreen" onClose={this.onRenewed} />
      );
    }
    return (
      <>
        {canRenew && (
        <Button variant="outlined" onClick={this.handleRenew} className={classes.button}>
          Renew
        </Button>
        )}
        { (waitlist > items) && (
        <Typography className={classes.waitlist}>
          <WarningIcon className={classes.warningIcon} />
          {' '}
          Waitlist started, no renewals
        </Typography>
        )}
        { remainingSeconds >= 0 && remainingSeconds < fifteenMinutes && (
          <CdlCountdown remainingSeconds={remainingSeconds} />) }
      </>
    );
  }
}

/** */
const styles = (theme) => ({
  button: {
    backgroundColor: theme.palette.background.paper,
    marginLeft: theme.spacing(5),
    order: 99,
    paddingBottom: 0,
    paddingTop: 0,
  },
  dueInformation: {
    display: 'inline-flex',
  },
  icon: {
    marginRight: theme.spacing(2),
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
    color: theme.palette.primary.main,
    display: 'inline-flex',
    marginLeft: theme.spacing(5),
  },
  warningIcon: {
    color: theme.palette.notification.main,
  },
});

export default withStyles(styles)(CdlLogout);
