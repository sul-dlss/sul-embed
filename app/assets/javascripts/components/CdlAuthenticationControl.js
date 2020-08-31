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
import AuthenticationLogout from 'mirador/dist/es/src/containers/AuthenticationLogout.js';


class CdlAuthenticationControl extends Component {
  constructor(props) {
    super(props);

    this.state = {
      statusText: null,
      open: false,
      showFailureMessage: true,
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

  authLabel(isInFailureState) {
    const { failureHeader, label } = this.props;
    const { statusText } = this.state;
    if (statusText) return statusText;
    return (isInFailureState ? failureHeader : label) || t('authenticationRequired');
  }

  /** */
  loginButtonText() {
    const { available } = this.props;
    if (available === false) return 'Join waitlist';
  }

  render() {
    const {
      classes,
      confirmLabel,
      degraded,
      description,
      failureDescription,
      failureHeader,
      header,
      label,
      profile,
      status,
      t,
      windowId,
    } = this.props;

    const failed = status === 'failed';
    if ((!degraded || !profile) && status !== 'fetching') return <AuthenticationLogout windowId={windowId} />;
    if (!this.isInteractive() && !failed) return <></>;

    const { showFailureMessage, open } = this.state;

    const isInFailureState = showFailureMessage && failed;

    const hasCollapsedContent = isInFailureState
      ? failureDescription
      : header || description;

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
          </Typography>
          { confirmButton }
        </div>
      </Paper>
    );
  }
}


const styles = theme => ({
  availableIcon: {
    color: '#009b76'
  },
  avatar: {
    backgroundColor: 'white',
    height: '1.5em',
    width: '1.5em',
  },
  label: {
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
  }
});

CdlAuthenticationControl.propTypes = {
  classes: PropTypes.objectOf(PropTypes.string).isRequired,
  confirmLabel: PropTypes.string,
  degraded: PropTypes.bool,
  description: PropTypes.string,
  failureDescription: PropTypes.string,
  failureHeader: PropTypes.string,
  handleAuthInteraction: PropTypes.func.isRequired,
  header: PropTypes.string,
  infoId: PropTypes.string,
  label: PropTypes.string,
  profile: PropTypes.string,
  serviceId: PropTypes.string,
  status: PropTypes.oneOf(['ok', 'fetching', 'failed', null]),
  t: PropTypes.func,
  windowId: PropTypes.string.isRequired,
};

CdlAuthenticationControl.defaultProps = {
  confirmLabel: undefined,
  degraded: false,
  description: undefined,
  failureDescription: undefined,
  failureHeader: undefined,
  header: undefined,
  infoId: undefined,
  label: undefined,
  profile: undefined,
  serviceId: undefined,
  status: null,
  t: () => {},
};

export default withStyles(styles)(CdlAuthenticationControl);
