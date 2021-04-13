import React, { useEffect, useRef } from 'react';
import PropTypes from 'prop-types';
import * as THREE from 'three';
import { MTLLoader } from 'three/examples/jsm/loaders/MTLLoader';
import { OBJLoader } from 'three/examples/jsm/loaders/OBJLoader';
import { WEBGL } from 'three/examples/jsm/WebGL';
import { Viewport } from 'virtex3d';

/** */
function Virtex({ threeDResource, windowId }) {
  const ref = useRef();

  /** */
  useEffect(() => {
    console.log(ref);
    console.log((!ref.current));
    if (!ref.current || !threeDResource) {
      return;
    }

    global.THREE = {
      MTLLoader,
      OBJLoader,
      ...THREE,
    };

    // Virtex uses a global Detector.  Three refactored this into the WEBGL library (and changed the API)
    // This is compatibility layer between what Vitex expects from the old Detector to the new WEBGL library.
    global.Detector = {
      webgl: WEBGL.isWebGLAvailable(),
      addGetWebGLMessage: WEBGL.getErrorMessage,
    };

    const viewport = new Viewport({
      data: {
        file: threeDResource.id,
        fullscreenEnabled: true,
        showStats: false,
      },
      target: ref.current,
    });
  }, []);

  // TODO: Setup +/- buttons and fullscreen somehow

  return (
    <section
      id={`${windowId}-virtex`}
      ref={ref}
      style={{ width: '100%' }}
    />
  );
}

Virtex.propTypes = {
  threeDResource: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  windowId: PropTypes.string.isRequired,
};

export default Virtex;
