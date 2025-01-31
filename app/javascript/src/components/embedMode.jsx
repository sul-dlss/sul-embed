import React from 'react';
import MenuItem from '@mui/material/MenuItem';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import Dialog from '@mui/material/Dialog';
import DialogTitle from '@mui/material/DialogTitle';
import DialogContent from '@mui/material/DialogContent';
import DialogContentText from '@mui/material/DialogContentText';
import DialogActions from '@mui/material/DialogActions';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import TextField from '@mui/material/TextField';
import CompareIcon from '@mui/icons-material/Compare';

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
