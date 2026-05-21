import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    iso: String,
  }

  connect() {
    const date = new Date(this.isoValue)
    if (Number.isNaN(date.getTime())) return

    const formatter = new Intl.DateTimeFormat(undefined, {
      month: "short",
      day: "numeric",
      hour: "numeric",
      minute: "2-digit",
    })

    this.element.textContent = formatter.format(date)
  }
}