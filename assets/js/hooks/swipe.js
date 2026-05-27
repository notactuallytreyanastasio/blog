const Swipe = {
  mounted() {
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

      // Fire as soon as finger moves 20px in a clear direction
      if (Math.max(absDx, absDy) < 20) return;

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
  }
};

export default Swipe;
