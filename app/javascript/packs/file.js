import { CssInjection } from '../../assets/javascripts/modules/css_injection';
import { EmbedThis } from '../../assets/javascripts/modules/embed_this';
import { PopupPanels } from '../../assets/javascripts/modules/popup_panels';
import FileSearch from '../../assets/javascripts/modules/file_search';
import FilePreview from '../../assets/javascripts/modules/file_preview';
import CommonViewerBehavior from '../../assets/javascripts/modules/common_viewer_behavior';

import '../../assets/javascripts/vendor/tooltip';

CssInjection.injectFontIcons();
CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer();
FileSearch.init();
FilePreview.init();
PopupPanels.init();
EmbedThis.init();
