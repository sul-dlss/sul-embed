import flatten from 'lodash/flatten';
import flattenDeep from 'lodash/flattenDeep';
import { getCurrentCanvas } from 'mirador/dist/es/src/state/selectors';
import ThreeDViewer from '../components/ThreeDViewer';

/** */
function threeDResources(canvas) {
  if (canvas !== undefined) {
    const resources = flattenDeep([
      canvas.getContent().map(i => i.getBody()),
    ]);
    // Note: IIIF adopters seems to be using Type == Model instead
    return flatten(resources.filter((resource) => resource.getProperty('type') === 'PhysicalObject'));
  }
  else {
    return [];
  }
}

/** */
const mapStateToProps = (state, { canvasId, windowId }) => {
  const canvas = getCurrentCanvas(state, { canvasId, windowId });
  return {
    threeDResources: threeDResources(canvas),
  };
};

export default {
  component: ThreeDViewer,
  mapStateToProps,
  mode: 'wrap',
  target: 'PrimaryWindow',
};
