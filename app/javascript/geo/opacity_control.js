export class OpacityControl {
  constructor(callback, initialOpacity = 0.75) {
    this.callback = callback
    this.initialOpacity = initialOpacity
  }

  onAdd(map) {
    this.map = map

    this.container = document.createElement("div")
    this.container.className = "opacity-control maplibregl-ctrl"

    const label = document.createElement("label")
    label.className = "opacity-label visually-hidden"
    label.textContent = "Opacity"

    const slider = document.createElement("input")
    slider.type = "range"
    slider.title = "Opacity"
    slider.className = "opacity-slider"
    slider.min = "0"
    slider.max = "100"
    slider.step = "1"
    slider.value = String(Math.round(this.initialOpacity * 100))
    slider.setAttribute("aria-label", "Layer opacity")

    slider.addEventListener("input", e => {
      this.callback(parseInt(e.target.value) / 100)
    })

    // Prevent map interactions from passing through the control
    this.container.addEventListener("click", e => e.stopPropagation())
    this.container.addEventListener("mousedown", e => e.stopPropagation())

    this.container.append(label, slider)
    return this.container
  }

  onRemove() {}
}
