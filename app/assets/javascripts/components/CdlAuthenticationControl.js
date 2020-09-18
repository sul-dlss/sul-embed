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
// import AuthenticationLogout from 'mirador/dist/es/src/containers/AuthenticationLogout';
import {
  getCurrentCanvas,
  getWindow,
  selectCurrentAuthServices,
} from 'mirador/dist/es/src/state/selectors';
import DueDate from './DueDate';

/** */
class CdlAuthenticationControl extends Component {

  /** */
  availabilityIcon() {
    const { available, nextUp, classes } = this.props;
    let icon = null;
    if (available === undefined) {
      icon = <LockIcon fontSize="small" color="primary" />;
    }
    if (available || nextUp) {
      icon = <CheckIcon fontSize="small" className={classes.availableIcon} />;
    } else {
      icon = <CloseIcon fontSize="small" color="primary" />;
    }
    return (
      <Avatar className={classes.avatar}>
        {icon}
      </Avatar>
    );
  }

  /** */
  authLabel(isInFailureState) {
    const {
      available, failureHeader, label, loanPeriod, nextUp,
    } = this.props;
    if (isInFailureState) return failureHeader;
    if (available === undefined) return label;

    if (available || nextUp) {
      return `Available for ${Math.floor(loanPeriod / 3600)}-hour loan`;
    }

    return 'Checked out';
  }

  /** */
  loginButtonText() {
    const {
      available, confirmLabel, items, nextUp, waitlist, label,
    } = this.props;
    
    console.log(this.props);

    if (nextUp) return null;

    if (available === false) {
      const waitListCount = waitlist > items ? `(${waitlist - 1})` : '';
      return (
        <>
          {['Join waitlist', waitListCount].join(' ')}
        </>
      );
    }
    return confirmButton;
  }

  /** */
  render() {
    const {
      classes, dueDate, targetProps, TargetComponent,
    } = this.props;
    const {
      status,
    } = targetProps;
    const pluginComponents = [DueDate];
    return (
      <TargetComponent
        icon={this.availabilityIcon()}
        {...targetProps}
        confirmButton={this.loginButtonText()}
        header={null}
        label={this.authLabel((status === 'failed'))}
        PluginComponents={pluginComponents}
        timestamp={dueDate}
        classes={classes}
      />
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
    marginRight: theme.spacing(1),
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
  infoId: PropTypes.string,
  items: PropTypes.number,
  label: PropTypes.string,
  loanPeriod: PropTypes.number,
  nextUp: PropTypes.bool,
  profile: PropTypes.string,
  serviceId: PropTypes.string,
  status: PropTypes.oneOf(['ok', 'token', 'cookie', 'fetching', 'failed', null]),
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
  items: undefined,
  label: undefined,
  loanPeriod: undefined,
  nextUp: undefined,
  profile: undefined,
  serviceId: undefined,
  status: null,
  t: () => {},
  waitlist: undefined,
};

/** */
const mapStateToProps = (state, { targetProps }) => {
  const { windowId } = targetProps;
  const canvasId = (getCurrentCanvas(state, { windowId }) || {}).id;
  const service = selectCurrentAuthServices(state, { canvasId, windowId });
  const window = getWindow(state, { windowId }) || {};
  const cdlAvailability = window.cdlAvailability || {};

  return {
    available: cdlAvailability.available,
    dueDate: cdlAvailability.dueDate,
    items: cdlAvailability.items,
    loanPeriod: cdlAvailability.loanPeriod,
    nextUp: window.cdl && (cdlAvailability.nextUps || []).includes(window.cdl.cdlHoldRecordId),
    service,
    waitlist: cdlAvailability.waitlist,
  };
};

const CdlAuthenticationControlPlugin = {
  mapStateToProps,
};

export default withStyles(styles)(CdlAuthenticationControl);
export { CdlAuthenticationControlPlugin };
