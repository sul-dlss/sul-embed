/*global CssInjection */

import CssInjection from 'modules/css_injection';
import 'vendor/tooltip';
import CommonViewerBehavior from 'modules/common_viewer_behavior';
import FileSearch from 'modules/file_search';
import FilePreview from 'modules/file_preview';
import PopupPanels from 'modules/popup_panels';
import EmbedThis from 'modules/embed_this';

const cssInjector = new CssInjection();
cssInjector.injectFontIcons();
cssInjector.appendToHead();

const commonViewer = new CommonViewerBehavior();
commonViewer.initializeViewer();

const fileSearch = new FileSearch();
fileSearch.init();

const filePreview = new FilePreview();
filePreview.init();

const popupPanels = new PopupPanels();
popupPanels.init();

const embedThis = new EmbedThis();
embedThis.init();
