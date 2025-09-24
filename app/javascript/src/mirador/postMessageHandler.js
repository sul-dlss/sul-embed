import { getExportableState } from 'mirador'

/**
 * Attaches a window message listener to handle 'requestState' messages
 * from a parent frame, responding with Mirador viewer exportable state.
 */
export function handleViewerPostMessage(viewerInstance) {
  window.addEventListener('message', (event) => {
    const isStanfordOrigin = /(stanford\.edu|[\w-]+\.stanford\.edu)/.test(event.origin);
    const isDev = process.env.RAILS_ENV === 'development';

    if (!isStanfordOrigin && !isDev) return;
    if (!event?.data) return;

    let parsedData;
    try {
      parsedData = typeof event.data === 'string' ? JSON.parse(event.data) : event.data;
    } catch (error) {
      console.error('Failed to parse postMessage data:', error);
      return;
    }

    if (parsedData.type === 'requestState') {
      const state = viewerInstance.store.getState();
      const exportableState = getExportableState(state);

      const imageEl = viewerInstance.container.querySelector('[data-full-image]');
      const canvasCountEl = viewerInstance.container.querySelector('.mirador-canvas-count');

      const imageUrl = imageEl?.dataset?.fullImage?.split('*') || [];
      const canvasIndex = canvasCountEl?.textContent?.split(' of')[0] || null;

      window.parent.postMessage(
        JSON.stringify({
          type: 'stateResponse',
          data: {
            ...exportableState,
            iiif_images: imageUrl,
            canvas_index: canvasIndex,
          },
          source: 'sul-embed-mirador',
        }),
        event.origin
      );
    }
  });
}
