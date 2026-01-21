// Markdown editor hook for handling functionality like cursor position tracking
const MarkdownEditor = {
  mounted() {
    this.setupImagePaste();
    this.setupKeyboardShortcuts();
    this.setupDragDrop();
    this.setupFormatHandler();
  },

  setupFormatHandler() {
    this.handleEvent("apply_format", ({ type }) => {
      const textarea = this.el;
      const start = textarea.selectionStart;
      const end = textarea.selectionEnd;
      const selectedText = textarea.value.substring(start, end);
      const text = textarea.value;
      let replacement = null;
      let newCursorPos = null;

      switch (type) {
        case 'bold':
          if (selectedText) {
            replacement = `**${selectedText}**`;
            newCursorPos = start + replacement.length;
          } else {
            replacement = '****';
            newCursorPos = start + 2;
          }
          break;
        case 'italic':
          if (selectedText) {
            replacement = `*${selectedText}*`;
            newCursorPos = start + replacement.length;
          } else {
            replacement = '**';
            newCursorPos = start + 1;
          }
          break;
        case 'underline':
          if (selectedText) {
            replacement = `<u>${selectedText}</u>`;
            newCursorPos = start + replacement.length;
          } else {
            replacement = '<u></u>';
            newCursorPos = start + 3;
          }
          break;
        case 'h1':
          replacement = selectedText ? `# ${selectedText}` : '# ';
          newCursorPos = start + replacement.length;
          break;
        case 'h2':
          replacement = selectedText ? `## ${selectedText}` : '## ';
          newCursorPos = start + replacement.length;
          break;
        case 'h3':
          replacement = selectedText ? `### ${selectedText}` : '### ';
          newCursorPos = start + replacement.length;
          break;
        case 'bullet':
          replacement = selectedText ? `- ${selectedText}` : '- ';
          newCursorPos = start + replacement.length;
          break;
        case 'number':
          replacement = selectedText ? `1. ${selectedText}` : '1. ';
          newCursorPos = start + replacement.length;
          break;
        case 'quote':
          replacement = selectedText ? `> ${selectedText}` : '> ';
          newCursorPos = start + replacement.length;
          break;
        case 'code':
          if (selectedText) {
            if (selectedText.includes('\n')) {
              replacement = `\`\`\`\n${selectedText}\n\`\`\``;
            } else {
              replacement = `\`${selectedText}\``;
            }
            newCursorPos = start + replacement.length;
          } else {
            replacement = '``';
            newCursorPos = start + 1;
          }
          break;
        case 'link':
          if (selectedText) {
            replacement = `[${selectedText}](url)`;
            newCursorPos = start + selectedText.length + 3;
          } else {
            replacement = '[](url)';
            newCursorPos = start + 1;
          }
          break;
        case 'image':
          if (selectedText) {
            replacement = `![${selectedText}](url)`;
            newCursorPos = start + selectedText.length + 4;
          } else {
            replacement = '![](url)';
            newCursorPos = start + 2;
          }
          break;
      }

      if (replacement !== null) {
        textarea.value = text.substring(0, start) + replacement + text.substring(end);
        textarea.setSelectionRange(newCursorPos, newCursorPos);
        textarea.focus();
        textarea.dispatchEvent(new Event('input', { bubbles: true }));
        this.pushEvent("update_content", { value: textarea.value });
      }
    });
  },

  setupImagePaste() {
    this.el.addEventListener('paste', (event) => {
      const items = event.clipboardData?.items;
      if (!items) return;

      for (let i = 0; i < items.length; i++) {
        if (items[i].type.indexOf('image') !== -1) {
          event.preventDefault();
          const blob = items[i].getAsFile();
          this.handleImageFile(blob);
          break;
        }
      }
    });
  },

  setupDragDrop() {
    this.el.addEventListener('dragover', (event) => {
      event.preventDefault();
      this.el.classList.add('drag-over');
    });

    this.el.addEventListener('dragleave', () => {
      this.el.classList.remove('drag-over');
    });

    this.el.addEventListener('drop', (event) => {
      event.preventDefault();
      this.el.classList.remove('drag-over');

      const files = event.dataTransfer?.files;
      if (!files) return;

      for (let i = 0; i < files.length; i++) {
        if (files[i].type.indexOf('image') !== -1) {
          this.handleImageFile(files[i]);
          break;
        }
      }
    });
  },

  handleImageFile(file) {
    // Limit image size to prevent OOM (max 500KB)
    const MAX_SIZE = 500 * 1024;
    if (file.size > MAX_SIZE) {
      alert(`Image too large (${Math.round(file.size/1024)}KB). Max size is 500KB.`);
      return;
    }

    const reader = new FileReader();
    reader.onload = (e) => {
      const dataUrl = e.target.result;
      // Double-check base64 size
      if (dataUrl.length > 700000) {
        alert('Image too large after encoding. Please use a smaller image.');
        return;
      }
      // Insert at cursor position
      const textarea = this.el;
      const start = textarea.selectionStart;
      const end = textarea.selectionEnd;
      const text = textarea.value;
      const imageMd = `![image](${dataUrl})`;

      textarea.value = text.substring(0, start) + imageMd + text.substring(end);

      // Move cursor after the inserted image
      const newPos = start + imageMd.length;
      textarea.setSelectionRange(newPos, newPos);

      // Trigger the update event
      textarea.dispatchEvent(new Event('input', { bubbles: true }));
      this.pushEvent("update_content", { value: textarea.value });
    };
    reader.readAsDataURL(file);
  },

  setupKeyboardShortcuts() {
    this.el.addEventListener('keydown', (event) => {
      if (!(event.ctrlKey || event.metaKey)) return;

      const textarea = this.el;
      const start = textarea.selectionStart;
      const end = textarea.selectionEnd;
      const selectedText = textarea.value.substring(start, end);
      let replacement = null;
      let newCursorPos = null;

      switch (event.key.toLowerCase()) {
        case 'b': // Bold
          if (selectedText) {
            replacement = `**${selectedText}**`;
            newCursorPos = start + replacement.length;
          } else {
            replacement = '****';
            newCursorPos = start + 2;
          }
          break;
        case 'i': // Italic
          if (selectedText) {
            replacement = `*${selectedText}*`;
            newCursorPos = start + replacement.length;
          } else {
            replacement = '**';
            newCursorPos = start + 1;
          }
          break;
        case 'k': // Link
          if (selectedText) {
            replacement = `[${selectedText}](url)`;
            newCursorPos = start + selectedText.length + 3;
          } else {
            replacement = '[](url)';
            newCursorPos = start + 1;
          }
          break;
        case '`': // Code
          if (selectedText) {
            if (selectedText.includes('\n')) {
              replacement = `\`\`\`\n${selectedText}\n\`\`\``;
            } else {
              replacement = `\`${selectedText}\``;
            }
            newCursorPos = start + replacement.length;
          } else {
            replacement = '``';
            newCursorPos = start + 1;
          }
          break;
      }

      if (replacement !== null) {
        event.preventDefault();
        const text = textarea.value;
        textarea.value = text.substring(0, start) + replacement + text.substring(end);
        textarea.setSelectionRange(newCursorPos, newCursorPos);
        textarea.dispatchEvent(new Event('input', { bubbles: true }));
        this.pushEvent("update_content", { value: textarea.value });
      }
    });
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