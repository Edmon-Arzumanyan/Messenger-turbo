import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["files", "attachedFiles"]

  connect() {
    console.log("File preview controller connected")
  }

  previewFiles(event) {
    const attachedFiles = this.attachedFilesTarget
    attachedFiles.innerHTML = ""
    const files = event.target.files

    Array.from(files).forEach((file) => {
      const fileType = file.type

      if (fileType.startsWith("image/")) {
        const img = document.createElement("img")
        img.src = URL.createObjectURL(file)
        img.style.maxWidth = "100px"
        img.style.marginRight = "10px"
        attachedFiles.appendChild(img)
      } else if (fileType.startsWith("video/")) {
        const video = document.createElement("video")
        video.src = URL.createObjectURL(file)
        video.style.maxWidth = "150px"
        video.controls = true
        attachedFiles.appendChild(video)
      } else {
        const fileNameElement = document.createElement("div")
        fileNameElement.textContent = file.name
        attachedFiles.appendChild(fileNameElement)
      }
    })
  }
}
