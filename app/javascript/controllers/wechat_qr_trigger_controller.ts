import { Controller } from "@hotwired/stimulus"

export default class extends Controller<HTMLElement> {
  connect(): void {
    console.log("WechatQrTrigger connected")
  }

  disconnect(): void {
    console.log("WechatQrTrigger disconnected")
  }

  // Show the WeChat QR code modal by finding and triggering the main controller
  show(event: Event): void {
    event.preventDefault()
    
    // Find the modal element in the DOM
    const modalElement = document.querySelector('[data-wechat-qr-target="modal"]') as HTMLElement
    if (modalElement) {
      modalElement.classList.remove("hidden")
      document.body.style.overflow = "hidden"
    }
  }
}
