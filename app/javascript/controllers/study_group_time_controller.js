import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["start", "end"]

  connect() {
    this.syncEnd()
  }

  syncEnd() {
    const startValue = this.startTarget.value
    if (!startValue) return

    const startDate = new Date(startValue)
    if (Number.isNaN(startDate.getTime())) return

    const shouldAutoFill = !this.endTarget.value || (this.endTarget.dataset.autoFilled === "true" && this.endTarget.dataset.manualEdited !== "true")
    if (!shouldAutoFill) return

    const endDate = new Date(startDate.getTime() + 60 * 60 * 1000)
    this.endTarget.value = this.formatForDatetimeLocal(endDate)
    this.endTarget.dataset.autoFilled = "true"
    this.endTarget.dataset.manualEdited = "false"
  }

  markManual() {
    this.endTarget.dataset.manualEdited = "true"
  }

  formatForDatetimeLocal(date) {
    const pad = (value) => String(value).padStart(2, "0")

    return [
      date.getFullYear(),
      pad(date.getMonth() + 1),
      pad(date.getDate()),
    ].join("-") + `T${pad(date.getHours())}:${pad(date.getMinutes())}`
  }
}