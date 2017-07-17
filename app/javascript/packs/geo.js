import CssInjection from 'modules/css_injection';
import 'vendor/tooltip';
import CommonViewerBehavior from 'modules/common_viewer_behavior';
import GeoViewer from 'modules/geo_viewer';
import PopupPanels from 'modules/popup_panels';
import EmbedThis from 'modules/embed_this';

const cssInjector = new CssInjection();
cssInjector.injectFontIcons();
cssInjector.appendToHead();

const geoViewer = new GeoViewer();
const commonViewer = new CommonViewerBehavior();
commonViewer.initializeViewer(geoViewer);

const popupPanels = new PopupPanels();
popupPanels.init();

const embedThis = new EmbedThis();
embedThis.init();
