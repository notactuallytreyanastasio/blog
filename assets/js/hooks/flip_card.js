/**
 * FlipCard hook for Smart Steps scenario cards.
 *
 * Click once to flip (peek). Click again to select ("this one").
 * Matches the original React FlipChoice component behavior.
 *
 * Peer events (facilitator <-> participant sync via PubSub):
 *  - peer_glow / peer_unglow: highlight card on other screen
 *  - peer_flip / peer_unflip: mirror flip state
 *  - reset_cards: new scenario, reset all cards
 */
const FlipCard = {
  mounted() {
    const index = parseInt(this.el.dataset.index, 10);
    const inner = this.el.querySelector(".flip-inner");
    this._flipped = false;

    this.el.addEventListener("click", () => {
      if (this.el.dataset.selected === "true") return;

      if (!this._flipped) {
        // First click: flip to peek
        this._flipped = true;
        if (inner) inner.classList.add("flipped");
        this.pushEvent("card_hover", { index });
      } else {
        // Second click: select this card
        this.el.dataset.selected = "true";
        this.el.classList.add("selected");
        this.pushEvent("card_select", { index });
      }
    });

    this.el.addEventListener("keydown", (e) => {
      if (e.key === "Enter" || e.key === " ") {
        e.preventDefault();
        this.el.click();
      }
    });

    // Peer events from server
    this.handleEvent("peer_glow", ({ index: peerIndex }) => {
      if (peerIndex === index) this.el.classList.add("peer-glow");
    });

    this.handleEvent("peer_unglow", ({ index: peerIndex }) => {
      if (peerIndex === index) this.el.classList.remove("peer-glow");
    });

    this.handleEvent("peer_flip", ({ index: peerIndex }) => {
      if (peerIndex === index && inner) {
        inner.classList.add("flipped");
      }
    });

    this.handleEvent("peer_unflip", ({ index: peerIndex }) => {
      if (peerIndex === index && inner) {
        inner.classList.remove("flipped");
      }
    });

    this.handleEvent("reset_cards", () => {
      this._flipped = false;
      this.el.dataset.selected = "false";
      this.el.classList.remove("peer-glow", "selected");
      if (inner) inner.classList.remove("flipped");
    });
  },

  destroyed() {}
};

export default FlipCard;
