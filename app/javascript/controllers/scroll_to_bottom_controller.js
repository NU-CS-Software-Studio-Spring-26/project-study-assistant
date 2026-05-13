import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Scroll to bottom on first render
    requestAnimationFrame(() => {
      this.element.scrollTop = this.element.scrollHeight
    })

    // Auto-scroll when new messages are appended via Turbo Streams
    this.observer = new MutationObserver((mutations) => {
      for (const mutation of mutations) {
        if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
          // wait a frame for DOM layout before scrolling
          requestAnimationFrame(() => {
            this.element.scrollTop = this.element.scrollHeight

            try {
              const currentUserId = this.element.dataset.currentUserId
              if (currentUserId) {
                // Check the last child added (most recent message)
                const lastMessage = this.element.lastElementChild
                if (lastMessage && lastMessage.dataset && lastMessage.dataset.userId === String(currentUserId)) {
                  // Clear the input used for composing messages and trigger input event to update counters
                  const input = document.querySelector('input[data-character-counter-target="input"]')
                  if (input) {
                    input.value = ''
                    input.dispatchEvent(new Event('input', { bubbles: true }))
                  }
                }
              }
            } catch (e) {
              // noop; best-effort UX enhancement
            }
          })
        }
      }
    })

    this.observer.observe(this.element, { childList: true, subtree: false })
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }
}