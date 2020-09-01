import React, { Component } from 'react';
import { withStyles } from '@material-ui/core/styles';
import Paper from '@material-ui/core/Paper';
import Typography from '@material-ui/core/Typography';
import {
  getCurrentCanvas,
  getRequiredStatement,
  selectAuthStatus,
  selectCanvasAuthService,
  getWindow,
} from 'mirador/dist/es/src/state/selectors';
import SanitizedHtml from 'mirador/dist/es/src/containers/SanitizedHtml';


class CdlCopyright extends Component {
  /** */
  constructor(props) {
    super(props);

    this.timer = null;
  }

  componentDidMount() {
    this.timer = setInterval(() => this.forceUpdate(), 1000 * 15);
  }

  componentWillUnmount() {
    clearInterval(this.timer);
  }

  render() {
    const { classes, dueDate, requiredStatement, status, TargetComponent } = this.props;
    const dueDateObject = new Date(dueDate * 1000);

    if (status === 'ok' && (dueDateObject - Date.now()) >= 0) {
      return <TargetComponent {...this.props} />;
    }
    return (
      <Paper square className={classes.paper}>
        { requiredStatement && requiredStatement.reduce((acc, labelValuePair, i) => acc.concat([
          <Typography component="div" key={`value-${i}`} variant="h3" className={classes.statement}>
            <SanitizedHtml htmlString={labelValuePair.values.join(', ')} ruleSet="iiif"/>
          </Typography>
        ]), [])}
      </Paper>
    )
  }
}

const styles = (theme) => ({
  paper: {
    backgroundColor: theme.palette.background.paper,
    padding: theme.spacing(4),
  },
  statement: {
    '& p': {
      margin: theme.spacing(4),
    }
  }
})

const mapStateToProps = (state, { windowId }) => {
  const canvasId = (getCurrentCanvas(state, { windowId }) || {}).id;
  const service = selectCanvasAuthService(state, { canvasId, windowId });
  const window = getWindow(state, { windowId });
  const payload = window.cdlInfoResponse && window.cdlInfoResponse.payload;

  return {
    dueDate: (payload && payload.exp) || 0,
    requiredStatement: getRequiredStatement(state, { windowId }),
    status: service && selectAuthStatus(state, service),
  }
}

const CdlCopyrightPlugin = {
  mapStateToProps,
}

export default withStyles(styles)(CdlCopyright);
export { CdlCopyrightPlugin }
