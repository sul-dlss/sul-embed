(function(global) {
  global.sulEmbedDownloadPanel = (function() {
     var $downloadOptions = $('.sul-embed-download-options'),
         $btnDownloadPanel = $('.sul-embed-footer-tool[data-toggle="sul-embed-download-panel"]'),
         sizes = $downloadOptions.data('download-sizes'),
         sizeLevelMapping = { full: 0, xlarge: -1, large: -2, medium: -3, small: -4 },
         djatokaBaseResolution = 92,
         disableDownloadWidthCutoff = 300,
         defaultSize = 400,
         imageData, fullFileSize, fullWidth, fullHeight, label, stacksUrl,
         stanfordOnly, tooltipText, druid, imageId, levels;

    function init(data) {
      imageData = data;
      setProperties();
      updateDownloadLinks();
    }

    function updateDownloadLinks() {
      $('.sul-embed-download-panel .sul-embed-panel-item-label').html('(' + label + ')');

      $.each(sizes, function(index, size) {
        var dimensions = getDimensionsForSize(size),
            downloadLink = [stacksUrl, 'image', druid, imageId + '_' + size + '?action=download'].join('/'),
            $downloadSize = $downloadOptions.find('.sul-embed-download-' + size);

        $downloadSize.find('.sul-embed-download-dimensions').html(dimensions);

        if (size !== 'default') {
          $downloadSize.find('a.download-link').attr('href', downloadLink);

          if (stanfordOnly) {
            $downloadSize.find('.sul-embed-stanford-only a')
              .prop('title', tooltipText)
              .data('sul-embed-tooltip', 'true')
              .tooltip();

            $downloadSize.find('.sul-embed-stanford-only').show();
          }
        }
      });
    }

    function setProperties() {
      var parts = imageData['image-id'].split('%252F');

      druid = parts[0];
      imageId = parts[1];
      fullWidth = parseInt(imageData['iov-width'], 10);
      fullHeight = parseInt(imageData['iov-height'], 10);
      fullFileSize = parseInt(imageData['iov-file-size'], 10);
      stanfordOnly = imageData['iov-stanford-only'];
      tooltipText = imageData['iov-tooltip-text'] || '';
      label = imageData['iov-label'] || '';
      stacksUrl = $downloadOptions.data('stacks-url');
      levels = jp2Levels(fullWidth, fullHeight);
    }

    function getDimensionsForSize(size) {
      var levelDelta = 0,
          dimensions = { width: 0, height: 0 };

      if (size === 'default') {
        dimensions = getDimensionsForDefaultSize();
      } else {
        levelDelta = levels - getLevelForSize(size);
        dimensions.width = Math.round(fullWidth / Math.pow(2, levelDelta));
        dimensions.height = Math.round(fullHeight / Math.pow(2, levelDelta));
      }

      return [dimensions.width, 'x', dimensions.height].join(' ');
    }

    function getDimensionsForDefaultSize() {
      var aspectRatio = (fullWidth/fullHeight).toPrecision(2),
          width = defaultSize,
          height = 0;

      if (fullHeight > fullWidth) {
        height = defaultSize;
        width = Math.round(height * aspectRatio);
      } else {
        height = Math.round(width / aspectRatio);
      }

      return { width: width, height: height };
    }

    function getLevelForSize(size) {
      var level = 0;

      if (size !== 'default' && typeof sizeLevelMapping[size] !== 'undefined') {
        level = levels + sizeLevelMapping[size];
      }

      return level;
    }

    function jp2Levels(width, height) {
      var levels = 1;
          longestSideDimension = Math.max(width, height);

      while (longestSideDimension >= djatokaBaseResolution) {
        ++levels;
        longestSideDimension = Math.round(longestSideDimension / 2);
      }

      return levels;
    }

    function formatBytes(bytes) {
      var k = 1000,
          sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'],
          i = Math.floor(Math.log(bytes) / Math.log(k));

       if (bytes === 0) return '0 Byte';
       return (bytes / Math.pow(k, i)).toPrecision(3) + ' ' + sizes[i];
    }

    function disableDownloadButton() {
      var embedWidth = $("#sul-embed-object").outerWidth();

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
      update: function(data) {
        enableDownloadButton();
        init(data);
      },

      disableDownload: function() {
        disableDownloadButton();
      }
    };
  }());

})(this);
