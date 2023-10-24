import { CssInjection } from '../src/modules/css_injection.js';
import CommonViewerBehavior from '../src/modules/common_viewer_behavior.js';
import M3Viewer from '../src/modules/m3_viewer.js';

CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer(M3Viewer.init);
