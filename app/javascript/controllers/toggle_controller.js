import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // This maps to data-toggle-target="toggleable"
  static targets = [ "toggleable" ]

  toggle(event) {
    if (event) event.preventDefault()

    // NOTICE THE PLURAL: targets instead of target
    // This loops through EVERY element inside the card marked with the target tag
    this.toggleableTargets.forEach((element) => {
      element.classList.toggle("d-none")
    })
  }
}