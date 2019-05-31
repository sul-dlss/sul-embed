/*global CssInjection, M3Viewer, CommonViewerBehavior */

//= require modules/css_injection
//= require modules/common_viewer_behavior
//= require mirador/dist/mirador.min
//= require modules/m3_viewer

CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer(M3Viewer.init);
