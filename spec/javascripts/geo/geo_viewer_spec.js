//= require jquery
//= require modules/geo_viewer

'use strict';

describe('geo_viewer.js', function() {
  describe('loads and makes available modules', function() {
    it('GeoViewer is defined', function() {
      expect(GeoViewer).toBeDefined();
    });
  });
  describe('#init', function() {
    fixture.set('<div id="sul-embed-geo-map" data-bounding-box=\'[["38.298673' +
      '", "-123.387626"], ["39.399103", "-122.528843"]]\'></div>');
    it('initializes map', function() {
      GeoViewer.init();
    });
  });
});
