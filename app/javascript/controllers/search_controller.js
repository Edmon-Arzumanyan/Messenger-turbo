import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "query"]

  submit(event) {
    this.formTarget.requestSubmit()
  }

  clear(event) {
    this.queryTarget.value = ''
    this.formTarget.requestSubmit()
  }
}
