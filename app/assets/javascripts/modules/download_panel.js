(function(global) {
  global.sulEmbedDownloadPanel = (function() {
    var $downloadPanel = $('.sul-embed-download-panel');
    var $btnDownloadPanel = $('.sul-embed-footer-tool[data-sul-embed-toggle="' +
      'sul-embed-download-panel"]');
    var disableDownloadWidthCutoff = 400;
    var imageData;
    var imageLabel;
    var restrictions;

    function init() {
      updateDownloadLinks();
    }

    function updateDownloadLinks() {
      $('.sul-embed-download-panel .sul-embed-panel-item-label').html('(' +
        imageLabel + ')');
      var $downloadList = $('<ul class="sul-embed-download-list"></ul>');
      var $listMarkup = $('<li class="sul-embed-download-list-item"></li>');
      // Append a thumb download link
      $downloadList.append($listMarkup.clone()
        .append('<a target="_blank" rel="noopener noreferrer" class="download-link" href="' + imageData['@id'] +
        '/full/!' + disableDownloadWidthCutoff + ',' +
        disableDownloadWidthCutoff +
        '/0/default.jpg?download=true" download>Download Thumbnail</a>'));
      // Create download list from sizes
      $.each(imageData.sizes, function(index, size) {
        if (size.width === 400 && size.height === 400) {
          return;
        }
        var downloadUrl = imageData['@id'] + '/full/' + size.width + ',' +
          size.height + '/0/default.jpg?download=true';
        var list = $listMarkup.clone();
        var link = $('<a target="_blank" rel="noopener noreferrer" class="download-link" href="' + downloadUrl +
          '">Download (' + size.width + ' x ' + size.height + ')</a>');
        if (restrictions) {
          if (Math.max(size.width, size.height) > disableDownloadWidthCutoff) {
            list.addClass('sul-embed-stanford-only');
            list.attr('title', 'Available only to Stanford-affiliated patrons');
          }
        } else {
          link.attr('download', '');
        }
        list.append(link);
        $downloadList.append(list);
      });
      $downloadPanel.find('.sul-embed-download-list')
        .replaceWith($downloadList);
    }

    function disableDownloadButton() {
      var embedWidth = $('#sul-embed-object').outerWidth();

      $btnDownloadPanel.prop('disabled', true);

      if (embedWidth > disableDownloadWidthCutoff) {
        $btnDownloadPanel.text(' No image selected');
      }
    }

    function enableDownloadButton() {
      $btnDownloadPanel
        .prop('disabled', false)
        .text('');
    }


    return {
      /**
       * Public method to update the download panels
       * @param {Object} data IIIF info.json data
       * @param {String} label for the image
       * @param {Boolean} restrictions for the images
       */
      update: function(data, label, stanfordOnly) {
        imageData = data;
        imageLabel = label;
        restrictions = stanfordOnly;
        enableDownloadButton();
        init();
      },

      disableDownload: function() {
        disableDownloadButton();
      }
    };
  }());

})(this);
