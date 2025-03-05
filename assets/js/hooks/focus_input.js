const FocusInput = {
  mounted() {
    // Focus the input when mounted
    this.el.focus()

    // Add click handler to the document to refocus the input
    document.addEventListener('click', (e) => {
      // Don't refocus if clicking on a button
      if (!e.target.matches('button')) {
        this.el.focus()
      }
    })

    // Prevent default behavior on input to avoid unwanted mobile keyboard features
    this.el.addEventListener('input', (e) => {
      const key = e.data?.toLowerCase() || ''
      if (key.match(/^[a-z]$/)) {
        // Clear the input after processing
        this.el.value = ''
        // Push the key event
        this.pushEvent('key-press', { key })
      }
    })

    // Handle backspace
    this.el.addEventListener('keydown', (e) => {
      if (e.key === 'Backspace') {
        e.preventDefault()
        this.pushEvent('key-press', { key: 'Backspace' })
      } else if (e.key === 'Enter') {
        e.preventDefault()
        this.pushEvent('key-press', { key: 'Enter' })
      }
    })

    // Prevent the input from losing focus except on buttons
    this.el.addEventListener('blur', (e) => {
      if (!e.relatedTarget?.matches('button')) {
        setTimeout(() => this.el.focus(), 0)
      }
    })
  }
}

export default FocusInput