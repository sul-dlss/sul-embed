/*global CssInjection */

//= require common
//= require modules/css_injection
//= require modules/common_viewer_behavior
//= require modules/uv_viewer

CssInjection.injectFontIcons();
CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer();
UVViewer.init();
