import { useEffect, useCallback } from 'react';

/** OSD returns negative and float bounds */
const convertToIIIFCoords = (bounds) => {
  if (bounds < 0) return 0;
  return Math.round(bounds);
};

const onViewportChange = (event) => {
  const viewer = event.eventSource;
  const { viewport } = viewer;

  const imageBounds = viewport.viewportToImageRectangle(viewport.getBounds());
  const parsedBounds = `${convertToIIIFCoords(imageBounds.x)},${convertToIIIFCoords(imageBounds.y)},${convertToIIIFCoords(imageBounds.width)},${convertToIIIFCoords(imageBounds.height)}`;
  viewer.element.parentNode.setAttribute('data-xywh-coords', parsedBounds);
};

function XywhDataAttributePlugin({ viewer, windowId }) {
  useEffect(() => {
    if (!viewer) return undefined;

    viewer.element.parentNode.setAttribute('data-parent-window-id', windowId)
    viewer.addHandler('animation-finish', onViewportChange);

    return () => {
      viewer.removeHandler('animation-finish', onViewportChange);
    }
  }, [viewer, onViewportChange, windowId]);

  return null;
}

export default [
  {
    component: XywhDataAttributePlugin,
    mode: 'add',
    name: 'XywhPlugin',
    target: 'OpenSeadragonViewer',
  },
];
