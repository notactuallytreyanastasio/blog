const Swipe = {
  mounted() {
    document.documentElement.classList.add("twenty48-page");

    let startX = 0;
    let startY = 0;
    let swiped = false;

    this.el.addEventListener("touchstart", (e) => {
      const t = e.touches[0];
      startX = t.clientX;
      startY = t.clientY;
      swiped = false;
    }, { passive: true });

    this.el.addEventListener("touchmove", (e) => {
      if (swiped) return;

      const t = e.touches[0];
      const dx = t.clientX - startX;
      const dy = t.clientY - startY;
      const absDx = Math.abs(dx);
      const absDy = Math.abs(dy);

      // Fire as soon as finger moves 12px in a clear direction
      if (Math.max(absDx, absDy) < 12) return;

      // Prevent page scroll when swiping on the game board
      e.preventDefault();

      swiped = true;

      let direction;
      if (absDx > absDy) {
        direction = dx > 0 ? "right" : "left";
      } else {
        direction = dy > 0 ? "down" : "up";
      }

      this.pushEvent("swipe", { direction });
    }, { passive: false });
  },

  destroyed() {
    document.documentElement.classList.remove("twenty48-page");
  }
};

export default Swipe;
