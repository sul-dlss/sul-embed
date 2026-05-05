export class MaskToggleControl {
  constructor(onToggle, initiallyMasked = false) {
    this.onToggle = onToggle
    this.masked = initiallyMasked
  }

  onAdd() {
    this.container = document.createElement("div")
    this.container.className = "mask-toggle-control maplibregl-ctrl"

    this.container.innerHTML = `
      <label class="checkbox-container">
        <input type="checkbox" class="mask-toggle-checkbox">
        <span class="checkbox-icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-intersect icon-checked" viewBox="0 0 16 16">
            <path d="M0 2a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v2h2a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2v-2H2a2 2 0 0 1-2-2zm5 10v2a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1V6a1 1 0 0 0-1-1h-2v5a2 2 0 0 1-2 2zm6-8V2a1 1 0 0 0-1-1H2a1 1 0 0 0-1 1v8a1 1 0 0 0 1 1h2V6a2 2 0 0 1 2-2z"/>
          </svg>

          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-union icon-unchecked" viewBox="0 0 16 16">
            <path d="M0 2a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v2h2a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2v-2H2a2 2 0 0 1-2-2z"/>
          </svg>
        </span>
      </label>
    `

    this.checkbox = this.container.querySelector("input")
    this.updateButton()

    this.checkbox.addEventListener("change", () => {
      this.masked = this.checkbox.checked
      this.onToggle(this.masked)
    })

    return this.container
  }

  onRemove() {}

  updateButton() {
    this.checkbox.checked = this.masked
  }
}
