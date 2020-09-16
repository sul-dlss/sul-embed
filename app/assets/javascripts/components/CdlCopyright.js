import React, { Component } from 'react';
import { withStyles } from '@material-ui/core/styles';
import Paper from '@material-ui/core/Paper';
import Typography from '@material-ui/core/Typography';
import {
  getCurrentCanvas,
  getRequiredStatement,
  selectAuthStatus,
  selectCanvasAuthService,
} from 'mirador/dist/es/src/state/selectors';
import SanitizedHtml from 'mirador/dist/es/src/containers/SanitizedHtml';

/** */
class CdlCopyright extends Component {
  /** */
  render() {
    const {
      classes, requiredStatement, status, TargetComponent,
    } = this.props;

    if (status !== null || status === 'ok') {
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
      maxWidth: '30em',
    },
    display: 'flex',
    fontSize: '18pt',
    justifyContent: 'center',
  },
});

/** */
const mapStateToProps = (state, { windowId }) => {
  const canvasId = (getCurrentCanvas(state, { windowId }) || {}).id;
  const service = selectCanvasAuthService(state, { canvasId, windowId });

  return {
    requiredStatement: getRequiredStatement(state, { windowId }),
    status: service && selectAuthStatus(state, service),
  };
};

const CdlCopyrightPlugin = {
  mapStateToProps,
};

export default withStyles(styles)(CdlCopyright);
export { CdlCopyrightPlugin };
