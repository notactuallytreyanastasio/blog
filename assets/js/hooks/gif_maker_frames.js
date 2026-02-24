const GifMakerFrames = {
  mounted() {
    // Keyboard shortcut: Ctrl+A to select all
    this.keyHandler = (e) => {
      if ((e.ctrlKey || e.metaKey) && e.key === 'a' && this.el.matches(':hover')) {
        e.preventDefault();
        this.pushEvent("select_all", {});
      }
    };
    document.addEventListener('keydown', this.keyHandler);
  },

  destroyed() {
    if (this.keyHandler) {
      document.removeEventListener('keydown', this.keyHandler);
    }
  }
};

export default GifMakerFrames;
