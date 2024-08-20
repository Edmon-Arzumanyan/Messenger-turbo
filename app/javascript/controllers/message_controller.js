import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.scrollToBottom();
    clearMessageInput()
    console.log('dwad')
  }

  scrollToBottom() {
    this.element.scrollTop = this.element.scrollHeight;
  }

  clearMessageInput() {
    const messageInput = this.element.querySelector("textarea");
    if (messageInput) {
      messageInput.value = '';
    }
  }
}
