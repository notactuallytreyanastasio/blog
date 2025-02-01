let Highlight = {
  mounted() {
    this.highlight()
    this.handleEvent("highlight", () => this.highlight())
  },

  updated() {
    this.highlight()
  },

  highlight() {
    this.el.querySelectorAll('pre code').forEach(block => {
      hljs.highlightBlock(block);
    });
  }
}

export default Highlight; 