import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages", "messageBody", "files"]

  connect() {
    this.scrollToBottom();
    console.log('Message controller connected');
  }

  submit() {
    this.scrollToBottom();
    this.clearMessageInput();
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight;
  }

  clearMessageInput() {
    this.messageBodyTarget.value = '';
  }
}
