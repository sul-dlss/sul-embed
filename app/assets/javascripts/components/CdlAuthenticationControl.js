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
import DueDate from './DueDate';

/** */
class CdlAuthenticationControl extends Component {

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
      <Avatar className={classes.avatar}>
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
      available, confirmButton, items, nextUp, waitlist, status,
    } = this.props;

    // We don't have access to a log out service
    if (status === 'ok') return 'Check in early';
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
  modifyClasses() {
    const { classes, status } = this.props;
    const classesClone = { ...classes };
    if (status === 'ok') {
      classesClone.paper = classes.paperLoggedIn;
      classesClone.topBar = classes.topBarLoggedIn;
    }
    return classesClone;
  }

  /** */
  confirmProps() {
    const { status } = this.props;
    if (status === 'ok') {
      return {
        color: 'default',
        variant: 'outlined',
      };
    }
    return {
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
      dueDate, targetProps, TargetComponent, status,
    } = this.props;
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
        classes={this.modifyClasses()}
        ConfirmProps={this.confirmProps()}
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
  // label: {
  //   alignItems: 'center',
  //   display: 'inline-flex',
  //   flexDirection: 'row',
  //   marginLeft: theme.spacing(1),
  //   marginRight: theme.spacing(1),
  // },
  paper: {
    cursor: 'inherit !important',
  },
  paperLoggedIn: {
    backgroundColor: theme.palette.background.paper,
  },
  timerIcon: {
    color: theme.palette.text.primary,
  },
  topBar: {
    alignItems: 'center',
    display: 'inline-flex',
    paddingBottom: theme.spacing(1),
    paddingLeft: theme.spacing(1),
    paddingRight: theme.spacing(1),
    paddingTop: theme.spacing(1),
  },
  topBarLoggedIn: {
    '&:hover': {
      backgroundColor: '#F9F6EF',
    },
    alignItems: 'center',
    backgroundColor: '#F9F6EF',
    display: 'flex',
    justifyContent: 'inherit',
    padding: theme.spacing(1),
    textTransform: 'none',
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
