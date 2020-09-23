import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import LockIcon from '@material-ui/icons/LockSharp';
import CheckIcon from '@material-ui/icons/CheckSharp';
import CloseIcon from '@material-ui/icons/CloseSharp';
import TimerIcon from '@material-ui/icons/TimerSharp';
import SvgIcon from '@material-ui/core/SvgIcon';
import Avatar from '@material-ui/core/Avatar';
import {
  getCurrentCanvas,
  getWindow,
  selectCurrentAuthServices,
} from 'mirador/dist/es/src/state/selectors';
import { requestAccessToken } from 'mirador/dist/es/src/state/actions';
import DueDate from './DueDate';
import CdlLogout from './CdlLogout';

/** */
class CdlAuthenticationControl extends Component {
  /** */
  constructor(props) {
    super(props);

    this.timer = null;
  }

  /** */
  componentDidMount() {
    this.timer = setInterval(() => this.forceUpdate(), 1000 * 15);
  }

  /** */
  componentWillUnmount() {
    clearInterval(this.timer);
  }

  /** */
  availabilityIcon() {
    const {
      available, nextUp, classes, status,
    } = this.props;
    let icon = null;
    if (available === undefined) {
      icon = <LockIcon fontSize="small" color="primary" />;
    }
    if (available || nextUp) {
      icon = <CheckIcon fontSize="small" className={classes.availableIcon} />;
    } else {
      icon = <CloseIcon fontSize="small" color="primary" />;
    }
    if (status === 'ok') {
      icon = <TimerIcon className={classes.timerIcon} />;
    }
    return (
      <Avatar className={this.modifyClasses().avatar}>
        {icon}
      </Avatar>
    );
  }

  /** */
  authLabel(isInFailureState) {
    const {
      available, failureHeader, label, loanPeriod, nextUp, status,
    } = this.props;
    if (isInFailureState) return failureHeader;
    if (available === undefined) return label;

    if (available || nextUp) {
      return `Available for ${Math.floor(loanPeriod / 3600)}-hour loan`;
    }

    if (status === 'ok') return null;

    return 'Checked out';
  }

  /** */
  loginButtonText() {
    const {
      available, confirmButton, items, logoutService, nextUp, waitlist, status,
    } = this.props;

    // We don't have access to a log out service
    if (status === 'ok') return logoutService.getLabel()[0].value;
    if (nextUp) return confirmButton;

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
  modifyClasses() {
    const { classes, dueDate, status } = this.props;
    const classesClone = { ...classes };
    if (status === 'ok') {
      classesClone.avatar = classes.avatarLoggedIn;
      classesClone.paper = classes.paperLoggedIn;
      classesClone.topBar = classes.topBarLoggedIn;
    }
    const dueDateObject = new Date(dueDate * 1000);
    const remainingSeconds = Math.floor((dueDateObject - Date.now()) / 1000);

    const fifteenMinutes = 60 * 15;
    if (status === 'ok' && remainingSeconds < fifteenMinutes) {
      classesClone.avatar = classes.avatarWarning;
      classesClone.paper = classes.paperWarning;
      classesClone.topBar = classes.topBarWarning;
    }
    return classesClone;
  }

  /** */
  confirmProps() {
    const { status } = this.props;
    if (status === 'ok') {
      return {
        autoFocus: false,
        color: 'default',
        variant: 'outlined',
      };
    }
    return {
      autoFocus: false,
      endIcon: (
        <SvgIcon style={{ marginTop: '5px' }}>
          <svg xmlns="http://www.w3.org/2000/svg"><path d="M11 0H3C1.343 0 0 1.3 0 3v8c0 1.7 1.3 3 3 3h8a3 3 0 003-3V3c0-1.7-1.3-3-3-3zm-.486 4.736h-2.16V3.623H5.777v2.4l3.459.001 1.277 1.215v4.063l-1.242 1.245H4.735l-1.246-1.266v-1.81h2.398v.981h2.595l.002-2.292H4.729L3.486 6.918V2.91l1.462-1.458h4.146l1.42 1.458v1.826z" /></svg>
        </SvgIcon>
      ),
    };
  }

  /** */
  render() {
    const {
      accessTokenServiceId, availabilityDueDate, dueDate, renewServiceId,
      requestAccessToken, status, targetProps, TargetComponent,
    } = this.props;
    const pluginComponents = [DueDate];
    if (status === 'ok') {
      pluginComponents.push(CdlLogout);
    }
    return (
      <TargetComponent
        icon={this.availabilityIcon()}
        {...targetProps}
        confirmButton={this.loginButtonText()}
        header={null}
        label={this.authLabel((status === 'failed'))}
        PluginComponents={pluginComponents}
        classes={this.modifyClasses()}
        ConfirmProps={this.confirmProps()}
        timestamp={availabilityDueDate} // Used for DueDate
        dueDate={dueDate} // Used for CdlLogout
        renewServiceId={renewServiceId} // Used for CdlLogout
        accessTokenServiceId={accessTokenServiceId} // Used for CdlLogout
        requestAccessToken={requestAccessToken} // Used for CdlLogout
      />
    );
  }
}

/** */
const styles = theme => {
  const avatarBase = {
    backgroundColor: 'white',
    height: '1.5em',
    marginRight: theme.spacing(1),
    width: '1.5em',
  };
  const topBarBase = {
    alignItems: 'center',
    display: 'inline-flex',
    paddingBottom: theme.spacing(1),
    paddingLeft: theme.spacing(1),
    paddingRight: theme.spacing(1),
    paddingTop: theme.spacing(1),
  };
  return ({
    availableIcon: {
      color: '#009b76',
    },
    avatar: {
      ...avatarBase,
    },
    avatarLoggedIn: {
      ...avatarBase,
      backgroundColor: theme.palette.background.paper,
    },
    avatarWarning: {
      ...avatarBase,
      backgroundColor: '#F9F6EF',
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
      cursor: 'inherit !important', // Should be able to remove in rc7
    },
    paperLoggedIn: {
      backgroundColor: theme.palette.background.paper,
    },
    paperWarning: {
      backgroundColor: '#F9F6EF',
    },
    timerIcon: {
      color: theme.palette.text.primary,
    },
    topBar: {
      ...topBarBase,
    },
    topBarLoggedIn: {
      ...topBarBase,
      '&:hover': {
        backgroundColor: theme.palette.background.paper, // Should be able to remove in rc7
      },
      backgroundColor: theme.palette.background.paper,
    },
    topBarWarning: {
      ...topBarBase,
      '&:hover': {
        backgroundColor: '#F9F6EF', // Should be able to remove in rc7
      },
      backgroundColor: '#F9F6EF',
    },
  });
};

CdlAuthenticationControl.propTypes = {
  accessTokenServiceId: PropTypes.string,
  availabilityDueDate: PropTypes.string,
  available: PropTypes.bool,
  classes: PropTypes.objectOf(PropTypes.string).isRequired,
  confirmButton: PropTypes.string,
  degraded: PropTypes.bool,
  dueDate: PropTypes.number,
  failureHeader: PropTypes.string,
  infoId: PropTypes.string,
  items: PropTypes.number,
  label: PropTypes.string,
  loanPeriod: PropTypes.number,
  logoutService: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  nextUp: PropTypes.bool,
  profile: PropTypes.string,
  renewServiceId: PropTypes.string,
  requestAccessToken: PropTypes.func,
  serviceId: PropTypes.string,
  status: PropTypes.oneOf(['ok', 'token', 'cookie', 'fetching', 'failed', null]),
  t: PropTypes.func,
  TargetComponent: PropTypes.oneOfType([
    PropTypes.func,
    PropTypes.node,
  ]).isRequired,
  targetProps: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  waitlist: PropTypes.number,
  windowId: PropTypes.string.isRequired,
};

CdlAuthenticationControl.defaultProps = {
  accessTokenServiceId: null,
  availabilityDueDate: null,
  available: false,
  confirmButton: undefined,
  degraded: false,
  dueDate: null,
  failureHeader: undefined,
  infoId: undefined,
  items: undefined,
  label: undefined,
  loanPeriod: undefined,
  nextUp: undefined,
  profile: undefined,
  renewServiceId: undefined,
  requestAccessToken: () => {},
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
  const logoutService = service && service[0].getService('http://iiif.io/api/auth/1/logout');
  const renewService = service && service[0].getService('http://iiif.io/api/auth/1/renew');
  const accessTokenService = service && service[0].getService('http://iiif.io/api/auth/1/token');
  const payload = window.cdlInfoResponse && window.cdlInfoResponse.payload;
  return {
    accessTokenServiceId: accessTokenService && accessTokenService.id,
    availabilityDueDate: cdlAvailability.dueDate,
    available: cdlAvailability.available,
    dueDate: payload && payload.exp,
    items: cdlAvailability.items,
    loanPeriod: cdlAvailability.loanPeriod,
    logoutService,
    nextUp: window.cdl && (cdlAvailability.nextUps || []).includes(window.cdl.cdlHoldRecordId),
    renewServiceId: renewService && renewService.id,
    service,
    waitlist: cdlAvailability.waitlist,
  };
};

/** */
const mapDispatchToProps = {
  requestAccessToken,
};

const CdlAuthenticationControlPlugin = {
  mapDispatchToProps,
  mapStateToProps,
};

export default withStyles(styles)(CdlAuthenticationControl);
export { CdlAuthenticationControlPlugin };
