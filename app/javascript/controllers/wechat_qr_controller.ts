import { Controller } from "@hotwired/stimulus"

export default class extends Controller<HTMLElement> {
  static targets = ["modal"]

  declare readonly modalTarget: HTMLElement

  connect(): void {
    console.log("WechatQr connected")
  }

  disconnect(): void {
    console.log("WechatQr disconnected")
  }

  // Show the WeChat QR code modal
  show(event: Event): void {
    event.preventDefault()
    this.modalTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
  }

  // Hide the WeChat QR code modal
  hide(): void {
    this.modalTarget.classList.add("hidden")
    document.body.style.overflow = ""
  }

  // Close modal when clicking outside
  closeOnOutsideClick(event: Event): void {
    if (event.target === event.currentTarget) {
      this.hide()
    }
  }
}
