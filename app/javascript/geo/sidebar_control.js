export class SidebarControl {
  constructor(maxHeight) {
    this.maxHeight = maxHeight
  }

  onAdd() {
    const title = "Map Sheet"
    const body = "Click the map to inspect a sheet."

    this.container = document.createElement("div")
    this.container.className = "maplibregl-ctrl"
    this.container.innerHTML = `
      <div class="sul-embed-geo-sidebar">
        <div class="sul-embed-geo-sidebar-header">
          <h3>${title}</h3>
          <button aria-label="expand/collapse" aria-expanded="true" aria-controls="sidebarContent">
            <svg class="MuiSvgIcon-root KeyboardArrowUpSharp" focusable="false" aria-hidden="true" viewBox="0 0 24 24"><path d="M7.41 15.41 12 10.83l4.59 4.58L18 14l-6-6-6 6z"></path></svg>
          </button>
        </div>
        <div id="sidebarContent" class="sul-embed-geo-sidebar-content show">${body}</div>
      </div>`

    this.button = this.container.querySelector("button")
    this.content = this.container.querySelector(
      ".sul-embed-geo-sidebar-content"
    )

    this.container.addEventListener("click", e => {
      const button = e.target.closest("button")
      if (!button) return
      const contentEl = document.getElementById(
        button.getAttribute("aria-controls")
      )
      const expanded = button.getAttribute("aria-expanded") === "true"
      contentEl.classList.toggle("show", !expanded)
      button.setAttribute("aria-expanded", String(!expanded))
    })

    return this.container
  }

  onRemove() {}

  openWithContent(html) {
    this.button.setAttribute("aria-expanded", "true")
    this.content.classList.add("show")
    this.content.innerHTML = html
    this.content.style.maxHeight = this.maxHeight
    this.content.setAttribute("aria-hidden", "false")
  }
}
