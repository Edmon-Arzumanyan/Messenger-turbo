import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { lastSeenAt: String }
  static targets = ["status"]

  connect() {
    this.checkUserStatus()
    this.interval = setInterval(() => this.checkUserStatus(), 60000)
  }

  disconnect() {
    clearInterval(this.interval)
  }

  checkUserStatus() {
    const now = new Date();
    const lastSeenAt = new Date(this.lastSeenAtValue);

    if (isNaN(lastSeenAt.getTime())) {
      // Handle invalid date
      this.statusTarget.innerHTML = 'offline';
      return;
    }

    const differenceInSeconds = (now - lastSeenAt) / 1000;

    if (differenceInSeconds <= 300) {
      this.statusTarget.innerHTML = 'Online';
    } else if (differenceInSeconds <= 360) {
      const minutesAgo = Math.floor(differenceInSeconds / 60);
      this.statusTarget.innerHTML = `${minutesAgo} minute${minutesAgo > 1 ? 's' : ''} ago`;
    } else if (differenceInSeconds <= 3600) {
      const minutesAgo = Math.floor(differenceInSeconds / 60);
      this.statusTarget.innerHTML = `${minutesAgo} minute${minutesAgo > 1 ? 's' : ''} ago`;
    } else if (differenceInSeconds <= 86400) {
      const hoursAgo = Math.floor(differenceInSeconds / 3600);
      this.statusTarget.innerHTML = `${hoursAgo} hour${hoursAgo > 1 ? 's' : ''} ago`;
    } else {
      const daysAgo = Math.floor(differenceInSeconds / 86400);
      this.statusTarget.innerHTML = `${daysAgo} day${daysAgo > 1 ? 's' : ''} ago`;
    }
  }
}
