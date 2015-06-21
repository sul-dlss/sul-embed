// Require React libraries and components (this ordering is specific)
//= require vendor/es5-shim
//= require vendor/es5-sham
//= require react
//= require components
//= require react_ujs

//= require openseadragon/built-openseadragon/openseadragon/openseadragon.min
//= require modules/css_injection
//= require modules/download_panel
//= require vendor/tooltip
//= require modules/jquery.iiifOsdViewer
//= require modules/common_viewer_behavior
//= require modules/popup_panels
//= require modules/embed_this

CssInjection.injectFontAwesome();
CssInjection.appendToHead();
CssInjection.injectPluginStyles();
CommonViewerBehavior.showViewer();
PopupPanels.init();
EmbedThis.init();
embedIiifOsdViewer();

function embedIiifOsdViewer() {
  var $sulEmbedIiifOsd = $('.sul-embed-iiif-osd'),
      iiifServer = $sulEmbedIiifOsd.data('iiif-server'),
      iiifImageInfo = $sulEmbedIiifOsd.data('iiif-image-info'),
      count = iiifImageInfo.length,
      suffix = (count > 1) ? 's' : '';

  $('.sul-embed-iiif-osd').iiifOsdViewer({
    data: [{
      iiifServer: iiifServer,
      images: iiifImageInfo
    }]
  });

  $('h2.sul-embed-item-count').html(count + ' image' + suffix);
}
