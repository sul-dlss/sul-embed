export const sulTheme = {
  sul: {
    palette: {
      type: 'light',
      primary: { main: '#8c1515' },
      secondary: { main: '#8c1515' },
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
