import React from 'react';
import { MenuItem, ListItemIcon, ListItemText } from '@mui/material';
import CompareIcon from '@mui/icons-material/Compare';

export default function CompareMenuItem({ handleClose, updateWindow, windowId }) {
  if (windowId !== 'main') return null;

  const handleClickOpen = () => {
    updateWindow(windowId, { showCompareDialog: true });
    handleClose();
  };

  return (
    <MenuItem onClick={handleClickOpen}>
      <ListItemIcon><CompareIcon /></ListItemIcon>
      <ListItemText primary="Compare to..." />
    </MenuItem>
  );
}
