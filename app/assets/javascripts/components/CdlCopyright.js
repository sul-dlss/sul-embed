import React, { Component } from 'react';
import { withStyles } from '@material-ui/core/styles';
import Paper from '@material-ui/core/Paper';
import Typography from '@material-ui/core/Typography';
import {
  getAuth,
  getRequiredStatement,
  selectCurrentAuthServices,
} from 'mirador/dist/es/src/state/selectors';
import SanitizedHtml from 'mirador/dist/es/src/containers/SanitizedHtml';

/** */
class CdlCopyright extends Component {
  /** */
  render() {
    const {
      classes, requiredStatement, status, TargetComponent,
    } = this.props;

    if (status === 'ok') {
      return <TargetComponent {...this.props} />;
    }
    return (
      <Paper square className={classes.paper}>
        { requiredStatement && requiredStatement.reduce((acc, labelValuePair, i) => acc.concat([
          <Typography component="div" key={`value-${i}`} variant="h3" className={classes.statement}>
            <SanitizedHtml htmlString={labelValuePair.values.join(', ')} ruleSet="iiif" />
          </Typography>,
        ]), [])}
      </Paper>
    );
  }
}

/** */
const styles = (theme) => ({
  paper: {
    backgroundColor: theme.palette.background.paper,
    overflowY: 'scroll',
    width: '100%',
  },
  primaryWindow: {},
  statement: {
    '& p': {
      margin: theme.spacing(4),
    },
    '& p:first-of-type': {
      fontSize: '10pt',
      lineHeight: '14pt',
    },
    '& span': {
      maxWidth: '30em',
    },
    display: 'flex',
    fontSize: '18pt',
    justifyContent: 'center',
  },
});

/** */
const mapStateToProps = (state, { windowId }) => {
  const services = selectCurrentAuthServices(state, { windowId });

  // Ported containers/IIIFAuthentication.js Should this be a selector?
  // TODO: get the most actionable auth service...
  const service = services[0];

  const authStatuses = getAuth(state);
  const authStatus = service && authStatuses[service.id];

  let status = null;

  if (!authStatus) {
    status = null;
  } else if (authStatus.ok) {
    status = 'ok';
  }

  return {
    requiredStatement: getRequiredStatement(state, { windowId }),
    status,
  };
};

const CdlCopyrightPlugin = {
  mapStateToProps,
};

export default withStyles(styles)(CdlCopyright);
export { CdlCopyrightPlugin };
