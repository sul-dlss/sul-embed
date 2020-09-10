import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import Button from '@material-ui/core/Button';
import Paper from '@material-ui/core/Paper';
import Typography from '@material-ui/core/Typography';
import LockIcon from '@material-ui/icons/LockSharp';
import CheckIcon from '@material-ui/icons/CheckSharp';
import CloseIcon from '@material-ui/icons/CloseSharp';
import Avatar from '@material-ui/core/Avatar';
import SanitizedHtml from 'mirador/dist/es/src/containers/SanitizedHtml';
import AuthenticationLogout from 'mirador/dist/es/src/containers/AuthenticationLogout';
import {
  getCurrentCanvas,
  getWindow,
  selectCanvasAuthService,
} from 'mirador/dist/es/src/state/selectors';
import DueDate from './DueDate';

/** */
class CdlAuthenticationControl extends Component {
  /** */
  constructor(props) {
    super(props);

    this.state = {
      showFailureMessage: true,
      statusText: null,
    };

    this.handleConfirm = this.handleConfirm.bind(this);
  }

  /** */
  handleConfirm() {
    const {
      handleAuthInteraction, infoId, serviceId, windowId,
    } = this.props;
    handleAuthInteraction(windowId, infoId, serviceId);
    this.setState({ showFailureMessage: true });
  }

  /** */
  isInteractive() {
    const {
      profile,
    } = this.props;

    return profile === 'http://iiif.io/api/auth/1/clickthrough' || profile === 'http://iiif.io/api/auth/1/login';
  }

  /** */
  availabilityIcon() {
    const { available, classes } = this.props;
    if (available === undefined) {
      return <LockIcon fontSize="small" color="primary" />;
    }
    if (available) {
      return <CheckIcon fontSize="small" className={classes.availableIcon} />;
    }
    return <CloseIcon fontSize="small" color="primary" />;
  }

  /** */
  authLabel(isInFailureState) {
    const {
      available, failureHeader, label, loanPeriod,
    } = this.props;
    const { statusText } = this.state;
    if (statusText) return statusText;
    if (!available) return 'Checked out';
    if (available) return `Available for ${Math.floor(loanPeriod / 3600)}-hour loan`;
    return isInFailureState ? failureHeader : label;
  }

  /** */
  loginButtonText() {
    const { available, waitlist } = this.props;
    if (available === false) {
      return (
        <>
          Join waitlist (
          {waitlist}
          )
        </>
      );
    }
  }

  /** */
  render() {
    const {
      available,
      classes,
      confirmLabel,
      degraded,
      dueDate,
      profile,
      status,
      t,
      windowId,
    } = this.props;

    const failed = status === 'failed';

    if ((!degraded || !profile) && (status !== null || status === 'ok')) return <AuthenticationLogout windowId={windowId} />;
    if (!this.isInteractive() && !failed) return <></>;

    const { showFailureMessage } = this.state;

    const isInFailureState = showFailureMessage && failed;

    const confirmButton = (
      <Button onClick={this.handleConfirm} className={classes.buttonInvert} color="secondary" size="small">
        {this.loginButtonText() || confirmLabel || (this.isInteractive() ? t('login') : t('retry')) }
      </Button>
    );

    return (
      <Paper square elevation={4} color="secondary" classes={{ root: classes.paper }}>
        <div className={classes.topBar}>
          <Avatar className={classes.avatar}>
            {this.availabilityIcon()}
          </Avatar>
          <Typography className={classes.label} component="h3" variant="body1" color="inherit">
            <SanitizedHtml htmlString={this.authLabel(isInFailureState)} ruleSet="iiif" />
            <DueDate className={classes.dueDate} timestamp={available ? null : dueDate} />
          </Typography>
          { confirmButton }
        </div>
      </Paper>
    );
  }
}

/** */
const styles = theme => ({
  availableIcon: {
    color: '#009b76',
  },
  avatar: {
    backgroundColor: 'white',
    height: '1.5em',
    width: '1.5em',
  },
  buttonInvert: {
    marginLeft: theme.spacing(5),
  },
  dueDate: {
    marginLeft: theme.spacing(3),
    marginRight: theme.spacing(3),
  },
  expanded: {},
  failure: {},
  fauxButton: {},
  icon: {},
  label: {
    alignItems: 'center',
    display: 'inline-flex',
    flexDirection: 'row',
    marginLeft: theme.spacing(1),
    marginRight: theme.spacing(1),
  },
  paper: {
    cursor: 'inherit !important',
  },
  topBar: {
    alignItems: 'center',
    display: 'inline-flex',
    paddingBottom: theme.spacing(1),
    paddingLeft: theme.spacing(1),
    paddingRight: theme.spacing(1),
    paddingTop: theme.spacing(1),
  },
});

CdlAuthenticationControl.propTypes = {
  available: PropTypes.bool,
  classes: PropTypes.objectOf(PropTypes.string).isRequired,
  confirmLabel: PropTypes.string,
  degraded: PropTypes.bool,
  dueDate: PropTypes.string,
  failureHeader: PropTypes.string,
  handleAuthInteraction: PropTypes.func.isRequired,
  infoId: PropTypes.string,
  label: PropTypes.string,
  loanPeriod: PropTypes.number,
  profile: PropTypes.string,
  serviceId: PropTypes.string,
  status: PropTypes.oneOf(['ok', 'fetching', 'failed', null]),
  t: PropTypes.func,
  waitlist: PropTypes.number,
  windowId: PropTypes.string.isRequired,
};

CdlAuthenticationControl.defaultProps = {
  available: false,
  confirmLabel: undefined,
  degraded: false,
  dueDate: null,
  failureHeader: undefined,
  infoId: undefined,
  label: undefined,
  loanPeriod: undefined,
  profile: undefined,
  serviceId: undefined,
  status: null,
  t: () => {},
  waitlist: undefined,
};

/** */
const mapStateToProps = (state, { windowId }) => {
  const canvasId = (getCurrentCanvas(state, { windowId }) || {}).id;
  const service = selectCanvasAuthService(state, { canvasId, windowId });
  const window = getWindow(state, { windowId });
  const cdlAvailability = window && window.cdlAvailability;

  return {
    available: cdlAvailability && cdlAvailability.available,
    dueDate: cdlAvailability && cdlAvailability.dueDate,
    loanPeriod: cdlAvailability && cdlAvailability.loanPeriod,
    service,
    waitlist: window && window.cdlAvailability && window.cdlAvailability.waitlist,
  };
};

const CdlAuthenticationControlPlugin = {
  mapStateToProps,
};

export default withStyles(styles)(CdlAuthenticationControl);
export { CdlAuthenticationControlPlugin };
