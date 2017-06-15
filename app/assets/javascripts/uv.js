/*global CssInjection */

//= require modules/css_injection
//= require modules/common_viewer_behavior
//= require modules/popup_panels
//= require modules/embed_this

CssInjection.injectFontIcons();
CssInjection.appendToHead();
CommonViewerBehavior.initializeViewer();
PopupPanels.init();
EmbedThis.init();

var uv, manifest, urlDataProvider;
window.addEventListener('uvLoaded', function(e) {
  console.log('helloworld');
  urlDataProvider = new UV.URLDataProvider();
//  loadManifests(function() {
//    setSelectedManifest();
    setupUV();
//  });
}, false);


function setupUV() {
            var data = {
                iiifResourceUri: 'https://purl.stanford.edu/fw090jw3474/iiif/manifest',
                configUri: '/uv-config.json',
                collectionIndex: Number(urlDataProvider.get('c', 0)),
                manifestIndex: Number(urlDataProvider.get('m', 0)),
                sequenceIndex: Number(urlDataProvider.get('s', 0)),
                canvasIndex: Number(urlDataProvider.get('cv', 0)),
                rotation: Number(urlDataProvider.get('r', 0)),
                xywh: urlDataProvider.get('xywh', '')
            };
            uv = createUV('#uv', data, urlDataProvider);
            uv.on('created', function() {
                Utils.Urls.setHashParameter('manifest', manifest);
            });
        }
