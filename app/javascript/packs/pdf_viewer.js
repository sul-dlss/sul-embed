import PDFJSLib from 'pdfjs-dist';
import { CssInjection } from '../../assets/javascripts/modules/css_injection.js';
import { CommonViewerBehavior } from '../../assets/javascripts/modules/common_viewer_behavior.js';

CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer(function() {
  'use strict';
  var viewer = $('#pdf-viewer'),
      buttons = viewer.prev('.buttons'),
      pdfUrl = viewer.data('pdfUrl'),
      pdfDoc = null,
      pageNum = 1,
      pageRendering = false,
      pageNumPending = null,
      maxScale = 6,
      minScale = 0.8,
      scale = 0.8,
      canvas = viewer.find('canvas')[0],
      ctx = canvas.getContext('2d');

  function renderPage(num) {
    pageRendering = true;
    pdfDoc.getPage(num).then(function(page) {
      var viewport = page.getViewport(scale);
      canvas.height = viewport.height;
      canvas.width = viewport.width;
      // Render PDF page into canvas context
      var renderContext = {
        canvasContext: ctx,
        viewport: viewport
      };
      var renderTask = page.render(renderContext);

      // Wait for rendering to finish
      renderTask.promise.then(function() {
        pageRendering = false;
        if (pageNumPending !== null) {
          renderPage(pageNumPending);
          pageNumPending = null;
        }
      });
    });
  }

  function queueRenderPage(num) {
    if (pageRendering) {
      pageNumPending = num;
    } else {
      renderPage(num);
    }
  }

  buttons.find('.prev-page').on('click', function() {
    if (pageNum <= 1) {
      return;
    }
    pageNum--;
    queueRenderPage(pageNum);
  });

  buttons.find('.next-page').on('click', function() {
    if (pageNum >= pdfDoc.numPages) {
      return;
    }
    pageNum++;
    queueRenderPage(pageNum);
  });

  buttons.find('.zoom-in').on('click', function() {
    if (scale >= maxScale) return;

    scale = scale + 0.5;
    queueRenderPage(pageNum);
  });

  buttons.find('.zoom-out').on('click', function() {
    if (scale <= minScale) return;

    scale = scale - 0.5;
    queueRenderPage(pageNum);
  });

  PDFJSLib.GlobalWorkerOptions.workerSrc = viewer.data('workerUrl');
  PDFJSLib.getDocument(pdfUrl).promise.then(function(pdfDoc_) {
    pdfDoc = pdfDoc_;
    renderPage(pageNum);
  });
});
