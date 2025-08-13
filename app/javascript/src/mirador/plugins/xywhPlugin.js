import { useEffect } from 'react';

/** OSD returns negative and float bounds */
const convertToIIIFCoords = (bounds) => {
  if (bounds < 0) return 0;
  return Math.round(bounds);
};

const convertToRegionUrl = (imageBounds, image_url) => {
  const xywh = `${convertToIIIFCoords(imageBounds.x)},${convertToIIIFCoords(imageBounds.y)},${convertToIIIFCoords(imageBounds.width)},${convertToIIIFCoords(imageBounds.height)}`;
  return image_url + `/${xywh}/full/0/default.jpg`
};

const onViewportChange = (event) => {
  const viewer = event.eventSource;
  const { viewport } = viewer;

  let full_image = ''
  const itemCount = viewport.viewer.world.getItemCount();

  if (itemCount > 1){
    const item1 = viewport.viewer.world.getItemAt(0);
    const item2 = viewport.viewer.world.getItemAt(1);
    // item which is on the left is page1
    const [page1, page2] = item1.getBounds().x <= item2.getBounds().x ? [item1, item2] : [item2, item1];
    let page1_bounds = page1.viewportToImageRectangle(viewport.getBounds());
    let page2_bounds = page2.viewportToImageRectangle(viewport.getBounds());
    let visible_pages =[]
    if (page1_bounds.x <= page1.source.width){
      visible_pages.push(convertToRegionUrl(page1_bounds, page1.source._id))
    }
    if (page1.source.width - page1_bounds.x  < page1_bounds.width || page2_bounds.x > 0) {
      page2_bounds.width = page2_bounds.width - (page1.source.width - page1_bounds.x);
      visible_pages.push(convertToRegionUrl(page2_bounds, page2.source._id))
    }
    full_image = visible_pages.join("*")
  } else {
    const imageBounds = viewport.viewportToImageRectangle(viewport.getBounds());
    full_image = convertToRegionUrl(imageBounds, viewport.viewer.source._id)
  }
  viewer.element.parentNode.setAttribute('data-full-image', full_image);
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
