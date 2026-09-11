const ZiggyCopy = {
  mounted() {
    this.original = this.el.textContent;
    this.el.addEventListener("click", () => {
      const text = this.el.dataset.text || "";
      const done = () => {
        this.el.textContent = "Copied!";
        setTimeout(() => {
          this.el.textContent = this.original;
        }, 1200);
      };
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(done).catch(() => {
          this.el.textContent = "Copy failed";
        });
      } else {
        done();
      }
    });
  },
};

export default ZiggyCopy;
