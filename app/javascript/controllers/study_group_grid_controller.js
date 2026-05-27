import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    scale: Number,
    storageKey: String
  }

  static targets = ["grid", "slider", "label"]

  connect() {
    const storedScale = this.readStoredScale()
    const initialScale = storedScale || this.scaleValue || 1
    this.applyScale(initialScale)
  }

  select(event) {
    const scale = Number(event.currentTarget.value)
    if (!Number.isFinite(scale) || scale < 0.1) return

    this.applyScale(scale)
    this.storeScale(scale)
  }

  applyScale(scale) {
    const gridElement = this.hasGridTarget ? this.gridTarget : this.element
    gridElement.style.setProperty("--study-group-scale", scale)

    if (this.hasSliderTarget) this.sliderTarget.value = String(scale)

    if (this.hasLabelTarget) this.labelTarget.textContent = this.labelForScale(scale)
  }

  readStoredScale() {
    if (!this.hasStorageKeyValue) return null

    const rawValue = window.localStorage.getItem(this.storageKeyValue)
    const parsedValue = Number.parseFloat(rawValue)
    return Number.isFinite(parsedValue) && parsedValue > 0 ? parsedValue : null
  }

  storeScale(scale) {
    if (!this.hasStorageKeyValue) return

    window.localStorage.setItem(this.storageKeyValue, String(scale))
  }

  labelForScale(scale) {
    return `${Math.round(scale * 100)}%`
  }
}