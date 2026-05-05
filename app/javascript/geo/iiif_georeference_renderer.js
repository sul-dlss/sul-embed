export class IiifGeoreferenceRenderer {
  constructor(map, annotationUrl, addOpacityControl) {
    this.map = map
    this.annotationUrl = annotationUrl
    this.addOpacityControl = addOpacityControl
  }

  async render() {
    const { WarpedMapLayer } = await import("allmaps")

    const warpedMapLayer = new WarpedMapLayer()
    this.map.addLayer(warpedMapLayer)
    await warpedMapLayer.addGeoreferenceAnnotationByUrl(this.annotationUrl)
    this.addOpacityControl(opacity => warpedMapLayer.setOpacity(opacity), 1.0)
    this.map.fitBounds(warpedMapLayer.getBounds(), { padding: 20 })
  }
}
