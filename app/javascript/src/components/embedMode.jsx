import React from 'react';
import MenuItem from '@material-ui/core/MenuItem';
import ListItemIcon from '@material-ui/core/ListItemIcon';
import ListItemText from '@material-ui/core/ListItemText';
import Dialog from '@material-ui/core/Dialog';
import DialogTitle from '@material-ui/core/DialogTitle';
import DialogContent from '@material-ui/core/DialogContent';
import DialogContentText from '@material-ui/core/DialogContentText';
import DialogActions from '@material-ui/core/DialogActions';
import Typography from '@material-ui/core/Typography';
import Button from '@material-ui/core/Button';
import TextField from '@material-ui/core/TextField';
import CompareIcon from '@material-ui/icons/Compare';

export const AllowWindowTopBarCloseForNonMainWindows = ({ targetProps: props, TargetComponent}) => (
  <TargetComponent {...props} allowClose={props.windowId === 'main' ? false : true} />
);

export const AllowDragAndDrop = ({ targetProps: props, TargetComponent}) => (
  <TargetComponent {...props} isWorkspaceControlPanelVisible={true} classes={{ ...props.classes, workspaceWithControlPanel: '' }}/>
);

export const CompareMenuItem = ({ handleClose, updateWindow, windowId }) => {

  if (windowId !== 'main') return null;

  const handleClickOpen = () => {
    updateWindow(windowId, { showCompareDialog: true });
    handleClose();
  };

  return (
    <React.Fragment>
      <MenuItem onClick={handleClickOpen}>
        <ListItemIcon>
          <CompareIcon />
        </ListItemIcon>
        <ListItemText primaryTypographyProps={{ variant: 'body1' }}>
          Compare to...
        </ListItemText>
      </MenuItem>
    </React.Fragment>
  );
}

export const CompareDialog = ({ addWindow, handleClose, show = false, updateWindow, windowId }) => {
  const [url, setUrl] = React.useState('');

  const handleDialogClose = () => {
    updateWindow(windowId, { showCompareDialog: false });
  };

  const handleSubmit = (e) => {
    if (!url || !url.startsWith('http')) return;
    e.preventDefault();
    addWindow({ manifestId: url });
    setUrl('');
    handleDialogClose();
  }

  const handleChange = (e) => {
    setUrl(e.target.value);
  }

  return (
    <Dialog open={show} onClose={handleDialogClose} aria-labelledby="compare-form-dialog-title">
      <DialogTitle id="compare-form-dialog-title" disableTypography>
        <Typography variant="h2">Compare to...</Typography>
      </DialogTitle>
      <form onSubmit={handleSubmit}>
        <DialogContent>
          <TextField
            autoFocus
            type="text"
            value={url}
            variant="filled"
            onChange={handleChange}
            margin="dense"
            id="url"
            label="Resource location"
            helperText="The URL of a IIIF resource"
            InputLabelProps={{
              shrink: true,
            }}
            fullWidth
            style={{ minWidth: '50ch' }}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={handleDialogClose} size="small" color="primary">
            Cancel
          </Button>
          <Button variant="contained" size="small" disableElevation onClick={handleSubmit} color="primary">
            Compare
          </Button>
        </DialogActions>
      </form>
    </Dialog>
  );
}
