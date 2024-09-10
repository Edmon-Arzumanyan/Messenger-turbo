import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["div", "message", "files"]

  connect() {
    console.log("Message form controller connected")
  }

  resetForm() {
    // Scroll to the bottom of the messages div
    this.divTarget.scrollTo(0, this.divTarget.scrollHeight)

    // Clear message text area
    this.messageTarget.value = ''

    // Clear file input
    this.filesTarget.value = ''
  }
}
