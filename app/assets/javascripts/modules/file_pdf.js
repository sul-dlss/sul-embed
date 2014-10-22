// Module handles common viewer behaviors

(function( global ) {
  var Module = (function() {
    var fileUrl;

    return {
      init: function() {
        $("[data-sul-embed-pdf]").each(function() {
          fileUrl = $(this).data("sul-embed-pdf");
          // Set pdfjs worker
          // PDFJS.disableWorker = true;
          PDFJS.workerSrc = "http://127.0.0.1:3000/assets/pdfjs-dist/build/pdf.worker.js"

          PDFJS.getDocument(fileUrl).then(function(pdf) {
            pdf.getPage(1).then(function(page) {
              var scale = 1.5,
                viewport = page.getViewport(scale),
                canvas = document.getElementById("sul-embed-pdf-canvas"),
                context = canvas.getContext("2d");

              canvas.height = 900;
              canvas.width = 900;
              var renderContext = {
                canvasContext: context,
                viewport: viewport
              };
              page.render(renderContext);
            });
          });
        });
      }
    };
  })();

  global.FilePdf = Module;

})( this );
