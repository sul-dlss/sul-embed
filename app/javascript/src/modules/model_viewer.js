'use strict'

export default {
  init: function() {
    let modelViewer = document.getElementsByTagName('model-viewer')[0]

    document.querySelector('.zoom-in').addEventListener('click', function(e) {
      e.preventDefault()
      modelViewer.zoom(1)
    })

    document.querySelector('.zoom-out').addEventListener('click', function(e) {
      e.preventDefault()
      modelViewer.zoom(-1)
    })
  }
}
