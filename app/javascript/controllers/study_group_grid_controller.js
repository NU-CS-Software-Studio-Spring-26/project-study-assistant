import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    columns: Number,
    storageKey: String
  }

  static targets = ["grid", "label", "option"]

  connect() {
    const storedColumns = this.readStoredColumns()
    const initialColumns = storedColumns || this.columnsValue || 3
    this.applyColumns(initialColumns)
  }

  selectLayout(event) {
    const columns = Number(event.params.columns || event.currentTarget.dataset.columns)
    if (!Number.isFinite(columns)) return

    this.applyColumns(columns)
  }

  applyColumns(columns) {
    const normalizedColumns = this.normalizeColumns(columns)
    const scale = this.scaleForColumns(normalizedColumns)
    const gridElement = this.hasGridTarget ? this.gridTarget : this.element
    gridElement.style.setProperty("--study-group-columns", String(normalizedColumns))
    gridElement.style.setProperty("--study-group-scale", String(scale))

    if (this.hasLabelTarget) this.labelTarget.textContent = this.labelForColumns(normalizedColumns)

    this.updateActiveOption(normalizedColumns)
    this.storeColumns(normalizedColumns)
  }

  readStoredColumns() {
    if (!this.hasStorageKeyValue) return null

    const rawValue = window.localStorage.getItem(this.storageKeyValue)
    const parsedValue = Number.parseInt(rawValue, 10)
    return Number.isFinite(parsedValue) ? this.normalizeColumns(parsedValue) : null
  }

  storeColumns(columns) {
    if (!this.hasStorageKeyValue) return

    window.localStorage.setItem(this.storageKeyValue, String(columns))
  }

  normalizeColumns(columns) {
    return Math.min(3, Math.max(1, Math.round(columns)))
  }

  scaleForColumns(columns) {
    return 3 / columns
  }

  labelForColumns(columns) {
    return `${columns} per row`
  }

  updateActiveOption(columns) {
    if (!this.hasOptionTarget) return

    this.optionTargets.forEach((button) => {
      const isActive = Number(button.dataset.columns) === columns
      button.classList.toggle("is-active", isActive)
      button.setAttribute("aria-pressed", String(isActive))
    })
  }
}