export class OpacityControl {
  constructor(layerSpecs, initialOpacity = 0.75) {
    this.layerSpecs = layerSpecs
    this.initialOpacity = initialOpacity
    this.mouseMoveHandler = null
    this.mouseUpHandler = null
  }

  onAdd(map) {
    this.map = map
    const opacityPercent = Math.round(this.initialOpacity * 100)

    this.container = document.createElement("div")
    this.container.className = "opacity-control unselectable maplibregl-ctrl"

    const area = document.createElement("div")
    area.className = "opacity-area"

    const handle = document.createElement("div")
    handle.className = "opacity-handle"
    handle.setAttribute("tabindex", "0")
    handle.innerHTML = `
      <div class="opacity-arrow-up"></div>
      <div class="opacity-text">${opacityPercent}%</div>
      <div class="opacity-arrow-down"></div>`

    const bottom = document.createElement("div")
    bottom.className = "opacity-bottom"

    this.container.append(area, handle, bottom)

    handle.style.top = `calc(100% - ${opacityPercent}% - 12px)`
    bottom.style.top = `calc(100% - ${opacityPercent}%)`
    bottom.style.height = `${opacityPercent}%`

    // Prevent map interactions from passing through the control
    this.container.addEventListener("click", e => e.stopPropagation())
    this.container.addEventListener("mousedown", e => e.stopPropagation())

    const updateOpacity = opacity => {
      this.layerSpecs.forEach(({ id, property }) => {
        if (map.getLayer(id)) map.setPaintProperty(id, property, opacity)
      })
    }

    let dragStart = null
    let dragStartTop

    handle.addEventListener("mousedown", e => {
      dragStart = e.clientY
      dragStartTop = handle.offsetTop - 12
    })

    this.mouseMoveHandler = e => {
      if (dragStart === null) return
      const percentInverse =
        Math.max(0, Math.min(200, dragStartTop + e.clientY - dragStart)) / 2
      handle.style.top = `${percentInverse * 2 - 13}px`
      handle.querySelector(".opacity-text").innerHTML =
        `${Math.round((1 - percentInverse / 100) * 100)}%`
      bottom.style.height = `${Math.max(0, (100 - percentInverse) * 2 - 13)}px`
      bottom.style.top = `${Math.min(200, percentInverse * 2 + 13)}px`
      updateOpacity(1 - percentInverse / 100)
    }

    this.mouseUpHandler = () => {
      dragStart = null
    }

    document.addEventListener("mousemove", this.mouseMoveHandler)
    document.addEventListener("mouseup", this.mouseUpHandler)

    handle.addEventListener("keydown", e => {
      const current = parseInt(handle.querySelector(".opacity-text").innerHTML)
      let next =
        e.key === "ArrowUp"
          ? current + 1
          : e.key === "ArrowDown"
            ? current - 1
            : null
      if (next === null) return
      e.preventDefault()
      next = Math.max(0, Math.min(100, next))
      handle.style.top = `calc(100% - ${next}% - 12px)`
      handle.querySelector(".opacity-text").innerHTML = `${next}%`
      bottom.style.height = `${next}%`
      bottom.style.top = `calc(100% - ${next}%)`
      updateOpacity(next / 100)
    })

    return this.container
  }

  onRemove() {
    document.removeEventListener("mousemove", this.mouseMoveHandler)
    document.removeEventListener("mouseup", this.mouseUpHandler)
  }
}
