'use strict';

import EmbedThis from 'src/modules/embed_this'
import PopupPanels from 'src/modules/popup_panels'
import Fullscreen from 'src/modules/fullscreen'
import ModelViewer from 'src/modules/model_viewer'

import '@google/model-viewer'

document.addEventListener('DOMContentLoaded', () => {
  document.getElementById('sul-embed-object').hidden = false
  ModelViewer.init()
  PopupPanels.init()
  EmbedThis.init()
  Fullscreen.init('.sul-embed-3d')
})