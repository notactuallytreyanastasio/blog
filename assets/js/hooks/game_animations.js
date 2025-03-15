const GameAnimations = {
  mounted() {
    this.handleEvents();
    this.addAnimationStyles();
  },

  handleEvents() {
    // Listen for card played events
    this.handleEvent("card_played", ({ player }) => {
      this.animateCardFlip(player);
    });

    // Listen for war events
    this.handleEvent("war_triggered", () => {
      this.animateWar();
    });

    // Listen for round won events
    this.handleEvent("round_won", ({ winner }) => {
      this.animateCardsToWinner(winner);
    });
  },

  addAnimationStyles() {
    // Add custom CSS for animations if not already present
    if (!document.getElementById('game-animations-css')) {
      const style = document.createElement('style');
      style.id = 'game-animations-css';
      style.textContent = `
        @keyframes flipCard {
          0% { transform: rotateY(0deg); }
          50% { transform: rotateY(90deg); opacity: 0.8; }
          100% { transform: rotateY(0deg); }
        }

        @keyframes slideToLeft {
          0% { transform: translateX(0) scale(1); opacity: 1; }
          100% { transform: translateX(-150px) scale(0.5); opacity: 0; }
        }

        @keyframes slideToRight {
          0% { transform: translateX(0) scale(1); opacity: 1; }
          100% { transform: translateX(150px) scale(0.5); opacity: 0; }
        }

        @keyframes pulse {
          0% { transform: scale(1); }
          50% { transform: scale(1.1); }
          100% { transform: scale(1); }
        }

        @keyframes dealFromDeck {
          0% { transform: translateY(0) scale(0.8); opacity: 0.8; }
          100% { transform: translateY(0) scale(1); opacity: 1; }
        }

        @keyframes warPileGrow {
          0% { transform: scale(1); }
          50% { transform: scale(1.1); }
          100% { transform: scale(1); }
        }

        .animate-flip {
          animation: flipCard 0.6s ease-in-out forwards;
          transform-style: preserve-3d;
        }

        .animate-slide-left {
          animation: slideToLeft 0.8s ease-in-out forwards;
        }

        .animate-slide-right {
          animation: slideToRight 0.8s ease-in-out forwards;
        }

        .animate-deal {
          animation: dealFromDeck 0.4s ease-out forwards;
        }

        .animate-war-pile {
          animation: warPileGrow 0.5s ease-in-out 3;
        }

        .victory-glow {
          animation: victory-glow 1.5s infinite;
        }
      `;
      document.head.appendChild(style);
    }
  },

  animateCardFlip(player) {
    const cardElement = this.el.querySelector(`[data-${player}-card]`);
    const cardFront = cardElement?.querySelector('[data-card-front]');

    if (cardFront) {
      // First animate the card coming from the deck
      cardFront.classList.add('animate-deal');

      // Then flip it to show the value
      setTimeout(() => {
        cardFront.classList.add('animate-flip');
        cardElement.classList.add('z-20');
      }, 300);

      // Remove animation classes after they complete
      setTimeout(() => {
        cardFront.classList.remove('animate-flip', 'animate-deal');
        cardElement.classList.remove('z-20');
      }, 900);

      // Highlight the player's score indicator
      const scoreIndicator = this.el.querySelector(`[data-player="${player}"]`);
      if (scoreIndicator) {
        scoreIndicator.classList.add('highlight');
        setTimeout(() => {
          scoreIndicator.classList.remove('highlight');
        }, 800);
      }
    }
  },

  animateWar() {
    // Show war pile
    const warPile = this.el.querySelector('[data-war-pile]');
    if (warPile) {
      warPile.classList.remove('hidden');

      // Make war pile elements pulse
      const cards = warPile.querySelectorAll('.war-pile-card');
      cards.forEach((card, index) => {
        // Stagger the animations
        setTimeout(() => {
          card.classList.add('animate-war-pile');
        }, index * 100);

        setTimeout(() => {
          card.classList.remove('animate-war-pile');
        }, 1500 + (index * 100));
      });

      // Highlight the scoring area
      const scoringElement = this.el.querySelector('[data-scoring]');
      if (scoringElement) {
        scoringElement.classList.add('animate-pulse');
        setTimeout(() => {
          scoringElement.classList.remove('animate-pulse');
        }, 1500);
      }
    }
  },

  animateCardsToWinner(winner) {
    // Get elements
    const cardArea = this.el.querySelector('[data-card-area]');
    const player1Card = this.el.querySelector('[data-player1-card]');
    const player2Card = this.el.querySelector('[data-player2-card]');
    const player1Deck = this.el.querySelector('[data-player1-deck]');
    const player2Deck = this.el.querySelector('[data-player2-deck]');

    if (!cardArea || !player1Card || !player2Card) return;

    // Prevent user interaction during animation
    cardArea.style.pointerEvents = 'none';

    if (winner === 'player1') {
      // Animate cards moving to player 1's deck
      player1Card.classList.add('animate-slide-left');
      player2Card.classList.add('animate-slide-left');

      // Highlight the winner's deck
      if (player1Deck) {
        player1Deck.classList.add('victory-glow');
      }

      // Highlight the winner's score indicator
      const scoreIndicator = this.el.querySelector('[data-player="player1"]');
      if (scoreIndicator) {
        scoreIndicator.classList.add('highlight');
      }
    } else if (winner === 'player2') {
      // Animate cards moving to player 2's deck
      player1Card.classList.add('animate-slide-right');
      player2Card.classList.add('animate-slide-right');

      // Highlight the winner's deck
      if (player2Deck) {
        player2Deck.classList.add('victory-glow');
      }

      // Highlight the winner's score indicator
      const scoreIndicator = this.el.querySelector('[data-player="player2"]');
      if (scoreIndicator) {
        scoreIndicator.classList.add('highlight');
      }
    }

    // Reset animations after they complete
    setTimeout(() => {
      // Remove card animations
      player1Card.classList.remove('animate-slide-left', 'animate-slide-right');
      player2Card.classList.remove('animate-slide-left', 'animate-slide-right');

      // Remove deck highlighting
      if (player1Deck) {
        player1Deck.classList.remove('victory-glow');
      }
      if (player2Deck) {
        player2Deck.classList.remove('victory-glow');
      }

      // Remove score indicator highlighting
      const scoreIndicators = this.el.querySelectorAll('.score-indicator');
      scoreIndicators.forEach(indicator => {
        indicator.classList.remove('highlight');
      });

      // Hide war pile
      const warPile = this.el.querySelector('[data-war-pile]');
      if (warPile && !warPile.classList.contains('hidden')) {
        warPile.classList.add('hidden');
      }

      // Re-enable interaction
      cardArea.style.pointerEvents = '';
    }, 1000);
  }
};

export default GameAnimations;