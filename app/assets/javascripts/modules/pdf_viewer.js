'use strict';
import PDFJSLib from 'pdfjs-dist';

export default {
  viewer: function() { return $('#pdf-viewer'); },
  buttons: function() { return this.viewer().prevAll('.button'); },
  pdfUrl: function() { return this.viewer().data('pdfUrl'); },
  locationRestricted: function() { return this.viewer().data('locationRestricted'); },
  loadingSpinner: function() { return this.viewer().find('.loading-spinner'); },
  pdfDoc: null,
  pageNum: 1,
  pageRendering: false,
  pageNumPending: null,
  maxScale: 6,
  minScale: 0.8,
  scale: 0.8,
  canvas: function() { return this.viewer().find('canvas')[0]; },
  ctx: function() { return this.canvas().getContext('2d'); },

  renderPage: function(num) {
    var _this = this;
    _this.pageRendering = true;

    _this.pdfDoc.getPage(num).then(function(page) {
      _this.updateButtonState();
      var viewport = page.getViewport(_this.scale);
      _this.canvas().height = viewport.height;
      _this.canvas().width = viewport.width;
      // Render PDF page into canvas context
      var renderContext = {
        canvasContext: _this.ctx(),
        viewport: viewport
      };
      var renderTask = page.render(renderContext);

      // Wait for rendering to finish
      renderTask.promise.then(function() {
        _this.pageRendering = false;
        if (_this.pageNumPending !== null) {
          _this.renderPage(_this.pageNumPending);
          _this.pageNumPending = null;
        }
      });
    });
  },

  updateButtonState: function() {
    var nextButton = this.buttons().filter('.next-page'),
        prevButton = this.buttons().filter('.prev-page');

    if (this.pageNum >= this.pdfDoc.numPages) {
      nextButton.addClass('disabled');
    } else if (this.pageNum <= 1) {
      prevButton.addClass('disabled');
    } else {
      nextButton.removeClass('disabled');
      prevButton.removeClass('disabled');
    }
  },

  setupButtonListeners: function() {
    var _this = this;
    _this.buttons().filter('.prev-page').on('click', function() {
      _this.prevPage();
    });

    _this.buttons().filter('.next-page').on('click', function() {
      _this.nextPage();
    });

    _this.buttons().filter('.zoom-in').on('click', function() {
      _this.zoomIn();
    });

    _this.buttons().filter('.zoom-out').on('click', function() {
      _this.zoomOut();
    });
  },

  queueRenderPage: function(num) {
    if (this.pageRendering) {
      this.pageNumPending = num;
    } else {
      this.renderPage(num);
    }
  },

  init: function() {
    var _this = this;
    PDFJSLib.GlobalWorkerOptions.workerSrc = _this.viewer().data('workerUrl');
    PDFJSLib.getDocument(_this.pdfUrl()).promise.then(function(pdfDoc_) {
      _this.loadingSpinner().remove();
      _this.pdfDoc = pdfDoc_;
      _this.renderPage(_this.pageNum);
    }, function() {
      _this.viewer().addClass('error');
      _this.buttons().hide();
      if (_this.locationRestricted()) {
        _this.viewer().html(
          '<h2>' +
          '<span class="error-icon" aria-hidden="true">&#9888;</span> ' +
          'Restricted document cannot be viewed in your location.' +
          '<br />' +
          'See Access conditions for more information.' +
          '</h2>'
        );
      } else {
        _this.viewer().html(
          '<h2><span class="error-icon" aria-hidden="true">&#9888;</span> There was an issue viewing this document</h2>'
        );
      }
    });

    _this.setupButtonListeners();
  },

  nextPage: function() {
    if (this.pageNum >= this.pdfDoc.numPages) {
      return;
    }
    this.pageNum++;
    this.queueRenderPage(this.pageNum);
  },

  prevPage: function() {
    if (this.pageNum <= 1) {
      return;
    }
    this.pageNum--;
    this.queueRenderPage(this.pageNum);
  },

  zoomIn: function() {
    if (this.scale >= this.maxScale) return;

    this.scale = this.scale + 0.5;
    this.queueRenderPage(this.pageNum);
  },

  zoomOut: function() {
    if (this.scale <= this.minScale) return;

    this.scale = this.scale - 0.5;
    this.queueRenderPage(this.pageNum);
  },
};
