import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { lastSeenAt: String }
  static targets = ["icon"]

  connect() {
    this.checkOnlineStatus()
    this.interval = setInterval(() => this.checkOnlineStatus(), 60000)
  }

  disconnect() {
    clearInterval(this.interval)
  }

  checkOnlineStatus() {
    const now = new Date()
    const lastSeenAt = new Date(this.lastSeenAtValue)
    const differenceInSeconds = (now - lastSeenAt) / 1000

    if (differenceInSeconds <= 300) {
      this.updateIcon('bg-green-400')
    } else {
      this.updateIcon('bg-red-400')
    }
  }

  updateIcon(colorClass) {
    this.iconTarget.classList.remove('bg-green-400', 'bg-red-400')
    this.iconTarget.classList.add(colorClass)
  }
}
