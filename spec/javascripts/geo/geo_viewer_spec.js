const GeoViewer = require('../../../app/assets/javascripts/modules/geo_viewer.js');

describe('geo_viewer.js', () => {
  describe('loads and makes available modules', () => {
    it('GeoViewer is defined', () => {
      expect(GeoViewer).toBeDefined();
    });
  });
  describe('#init', () => {
    document.body.innerHTML = '<div id="sul-embed-geo-map" data-bounding-box=\'[["38.298673'
      + '", "-123.387626"], ["39.399103", "-122.528843"]]\'></div>';
    it('initializes map', () => {
      GeoViewer.init();
    });
  });
});
