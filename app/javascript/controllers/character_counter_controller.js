import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "counter"]
  static values = {
    maxLength: Number,
  }

  connect() {
    this.update()
  }

  update() {
    const currentLength = this.inputTarget.value.length
    this.counterTarget.textContent = `${currentLength}/${this.maxLengthValue}`
  }
}