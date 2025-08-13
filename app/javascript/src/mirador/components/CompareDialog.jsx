import React from 'react';
import {
  Dialog, DialogTitle, DialogContent,
  DialogActions, Button, Typography, TextField,
} from '@mui/material';

export default function CompareDialog({ addWindow, handleClose, show = false, updateWindow, windowId }) {
  const [url, setUrl] = React.useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!url?.startsWith('http')) return;
    addWindow({ manifestId: url });
    setUrl('');
    updateWindow(windowId, { showCompareDialog: false });
  };

  return (
    <Dialog open={show} onClose={() => updateWindow(windowId, { showCompareDialog: false })}>
      <DialogTitle disableTypography>
        <Typography variant="h2">Compare to...</Typography>
      </DialogTitle>
      <form onSubmit={handleSubmit}>
        <DialogContent>
          <TextField
            autoFocus fullWidth type="text" value={url}
            onChange={(e) => setUrl(e.target.value)}
            variant="filled" margin="dense" label="Resource location"
            helperText="The URL of a IIIF resource"
            InputLabelProps={{ shrink: true }}
            style={{ minWidth: '50ch' }}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => updateWindow(windowId, { showCompareDialog: false })}>Cancel</Button>
          <Button variant="contained" type="submit" disableElevation>Compare</Button>
        </DialogActions>
      </form>
    </Dialog>
  );
}
