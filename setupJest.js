import $ from 'jquery'; // eslint-disable-line import/no-extraneous-dependencies, import/no-unresolved
import { JSDOM } from 'jsdom'; // eslint-disable-line import/no-extraneous-dependencies

const jsdom = new JSDOM('<html></html>', {});

// svg CHEATING
const tempDocument = (new JSDOM('...')).window.document;
const svg = tempDocument.createElementNS('http://www.w3.org/2000/svg', 'svg');
// in this function, you need set the error about:
// property of "sth" undefined, to define a object
// "sth" is not a function, to define a function
// and so other errors
/**
 *  An approach to mocking the SVG needed functionality for Leaflet to render
 * Adapted from https://stackoverflow.com/questions/44173754/jsdom-not-support-svg
 */
function cheatCreateElementNS(ns, name) {
  const el = global.$(svg.outerHTML)[0];
  el.createSVGRect = () => {};
  el.createSVGPoint = () => ({
    matrixTransform: () => el.createSVGPoint(),
  });
  el.getScreenCTM = () => ({
    e: {},
  });
  return el;
}

document.createElementNS = cheatCreateElementNS;
global.window = jsdom.window;
global.document = jsdom.window.document;
global.jQuery = $;
global.$ = global.jQuery;

// Import after we have patched up document with the SVG polyfill
import * as L from 'leaflet-src.js.erb'; // eslint-disable-line import/no-extraneous-dependencies, import/first, import/no-unresolved
