export const sulTheme = {
  sul: {
    palette: {
      type: 'light',
      primary: { main: '#8c1515', contrastText: '#fff' },
      secondary: { main: '#8c1515', contrastText: '#fff' },
      shades: {
        dark: '#2e2d29',
        main: '#ffffff',
        light: '#f4f4f4',
      },
      notification: { main: '#e98300' },
    },
  },
};

export const viewerViews = [
  { key: 'single', behaviors: [null, 'individuals'] },
  { key: 'book', behaviors: [null, 'paged'] },
  { key: 'scroll', behaviors: ['continuous'] },
  { key: 'gallery' },
];

export const defaultWorkspace = (enableComparison) => ({
  showZoomControls: true,
  type: enableComparison ? 'mosaic' : 'single',
});
