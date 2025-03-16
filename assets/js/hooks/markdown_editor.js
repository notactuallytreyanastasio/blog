// Markdown editor hook for handling functionality like cursor position tracking
const MarkdownEditor = {
  mounted() {
    // Will be implemented if needed in the future
  }
}

// Hook for tracking cursor position in textarea
const MarkdownInput = {
  mounted() {
    this.handleCursorPosition();
    this.processServerPush();
    this.setupKeyboardShortcuts();
  },

  updated() {
    // The textarea value is already updated by LiveView when the assign changes
    // so we don't need to do anything special here
  },

  handleCursorPosition() {
    const textarea = this.el;

    textarea.addEventListener('click', () => {
      this.saveSelectionInfo();
    });

    textarea.addEventListener('keyup', () => {
      this.saveSelectionInfo();
    });

    textarea.addEventListener('select', () => {
      this.saveSelectionInfo();
    });

    // Also track mouseup for selection changes
    textarea.addEventListener('mouseup', () => {
      this.saveSelectionInfo();
    });
  },

  saveSelectionInfo() {
    const textarea = this.el;
    const start = textarea.selectionStart;
    const end = textarea.selectionEnd;
    const selectedText = textarea.value.substring(start, end);

    this.pushEvent("save_selection_info", {
      position: start.toString(),
      selection_start: start.toString(),
      selection_end: end.toString(),
      selected_text: selectedText
    });
  },

  setupKeyboardShortcuts() {
    this.el.addEventListener('keydown', (event) => {
      // Only process if ctrl/cmd key is pressed
      if (!(event.ctrlKey || event.metaKey)) return;

      let handled = false;

      switch (event.key.toLowerCase()) {
        case 'b': // Bold
          this.pushEvent("insert_format", { format: "bold" });
          handled = true;
          break;
        case 'i': // Italic
          this.pushEvent("insert_format", { format: "italic" });
          handled = true;
          break;
        case 'k': // Link
          this.pushEvent("insert_format", { format: "link" });
          handled = true;
          break;
      }

      if (handled) {
        event.preventDefault();
      }
    });
  },

  // Handle setting the cursor position from server
  processServerPush() {
    this.handleEvent("set_cursor_position", (payload) => {
      const position = parseInt(payload.position, 10);
      const textarea = this.el;

      textarea.focus();
      textarea.setSelectionRange(position, position);
    });

    this.handleEvent("set_selection_range", (payload) => {
      const start = parseInt(payload.start, 10);
      const end = parseInt(payload.end, 10);
      const textarea = this.el;

      textarea.focus();
      textarea.setSelectionRange(start, end);
    });

    // Handle markdown content updates
    this.handleEvent("update_markdown_content", (payload) => {
      const textarea = this.el;
      const selectionStart = textarea.selectionStart;
      const selectionEnd = textarea.selectionEnd;

      // Update the textarea value with the new markdown
      textarea.value = payload.content;

      // Restore cursor position if provided
      if (payload.selectionStart !== undefined && payload.selectionEnd !== undefined) {
        const start = parseInt(payload.selectionStart, 10);
        const end = parseInt(payload.selectionEnd, 10);
        textarea.setSelectionRange(start, end);
      } else {
        // Otherwise restore the previous selection
        textarea.setSelectionRange(selectionStart, selectionEnd);
      }
    });
  }
}

export { MarkdownEditor, MarkdownInput };
export default MarkdownEditor;