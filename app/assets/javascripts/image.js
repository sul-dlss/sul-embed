//= require openseadragon/built-openseadragon/openseadragon/openseadragon.min
//= require modules/css_injection
//= require modules/jquery.iiifOsdViewer
//= require modules/common_viewer_behavior
//= require modules/metadata_panel

CssInjection.injectFontAwesome();
CssInjection.appendToHead();
CssInjection.injectPluginStyles();
CommonViewerBehavior.showViewer();
embedIiifOsdViewer();
MetadataPanel.init();

function embedIiifOsdViewer() {
  var $sulEmbedIiifOsd = $('.sul-embed-iiif-osd'),
      iiifServer = $sulEmbedIiifOsd.data('iiif-server'),
      iiifImageIds = $sulEmbedIiifOsd.data('iiif-image-ids').split(',');

 $('.sul-embed-iiif-osd').iiifOsdViewer({
    images: [{
      iiifServer: iiifServer,
      ids: iiifImageIds
    }]
  });
}
