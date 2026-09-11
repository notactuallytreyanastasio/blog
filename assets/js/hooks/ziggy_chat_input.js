const ZiggyChatInput = {
  mounted() {
    this.currentSuggestion = null;
    this.lastKnownValue = this.el.value;
    this.autoGrow();
    this.updateGhostTyped();

    this.el.addEventListener("input", () => {
      this.lastKnownValue = this.el.value;
      this.autoGrow();
      this.updateGhostTyped();
      this.scheduleSuggest();
    });

    this.el.addEventListener("scroll", () => {
      const ghost = this.ghostEl();
      if (ghost) ghost.scrollTop = this.el.scrollTop;
    });

    this.el.addEventListener("keydown", (e) => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        this.clearSuggestion();
        if (this.el.value.trim() !== "" && this.el.form) this.el.form.requestSubmit();
      } else if (e.key === "Tab" && this.currentSuggestion) {
        e.preventDefault();
        this.acceptSuggestion();
      } else if (e.key === "Escape") {
        this.clearSuggestion();
      }
    });

    this.handleEvent("ziggy-suggestion", ({ for: forText, suggestion }) => {
      if (forText === this.el.value && suggestion) {
        this.currentSuggestion = suggestion;
        this.renderGhost();
      }
    });
  },

  updated() {
    // Don't blindly clear the suggestion here: delivering it is itself a
    // server round-trip (push_event), which can trigger this same callback
    // right as the suggestion arrives, wiping it before it's ever seen.
    // Only reset when the server actually changed the value out from under
    // us (e.g. clearing the draft after a message is sent).
    if (this.el.value !== this.lastKnownValue) {
      this.clearSuggestion();
    }
    this.autoGrow();
    this.updateGhostTyped();
    this.lastKnownValue = this.el.value;
  },

  ghostEl() {
    return this.el.parentElement.querySelector(".zg-ghost");
  },

  autoGrow() {
    this.el.style.height = "auto";
    this.el.style.height = this.el.scrollHeight + "px";
    const ghost = this.ghostEl();
    if (ghost) ghost.style.height = this.el.style.height;
  },

  updateGhostTyped() {
    const ghost = this.ghostEl();
    if (!ghost) return;
    ghost.querySelector(".typed").textContent = this.el.value;
  },

  clearSuggestion() {
    this.currentSuggestion = null;
    const ghost = this.ghostEl();
    if (ghost) ghost.querySelector(".suggestion").textContent = "";
  },

  renderGhost() {
    const ghost = this.ghostEl();
    if (!ghost) return;
    ghost.querySelector(".suggestion").textContent = this.currentSuggestion;
  },

  acceptSuggestion() {
    if (!this.currentSuggestion) return;
    this.el.value = this.el.value + this.currentSuggestion;
    this.lastKnownValue = this.el.value;
    this.clearSuggestion();
    this.autoGrow();
    this.updateGhostTyped();
    this.el.selectionStart = this.el.selectionEnd = this.el.value.length;
  },

  scheduleSuggest() {
    clearTimeout(this._t);
    this.clearSuggestion();
    const text = this.el.value;
    if (text.trim().length < 3) return;
    this._t = setTimeout(() => {
      this.pushEvent("suggest", { text });
    }, 450);
  },
};

export default ZiggyChatInput;
