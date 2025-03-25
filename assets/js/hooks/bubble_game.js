const ROWS = 8;
const COLS = 12;
const BUBBLE_RADIUS = 0.4;
const SHOOTER_Y = -8; // Position of the shooter
const SHOOT_SPEED = 0.3;
const COLORS = [
  0xff0000, // red
  0x00ff00, // green
  0x0000ff, // blue
  0xffff00, // yellow
  0xff00ff, // magenta
  0x00ffff  // cyan
];

class Bubble {
  constructor(color, position) {
    const geometry = new THREE.SphereGeometry(BUBBLE_RADIUS, 32, 32);
    const material = new THREE.MeshPhongMaterial({ color });
    this.mesh = new THREE.Mesh(geometry, material);
    this.mesh.position.copy(position);
    this.color = color;
    this.velocity = new THREE.Vector3(0, 0, 0);
    this.isMoving = false;
  }
}

class Shooter {
  constructor() {
    // Create shooter base
    const baseGeometry = new THREE.CylinderGeometry(0.5, 0.7, 1, 32);
    const baseMaterial = new THREE.MeshPhongMaterial({ color: 0x888888 });
    this.base = new THREE.Mesh(baseGeometry, baseMaterial);
    this.base.position.set(0, SHOOTER_Y, 0);

    // Create the arrow to show direction
    const arrowGeometry = new THREE.ConeGeometry(0.3, 1, 32);
    const arrowMaterial = new THREE.MeshPhongMaterial({ color: 0xffffff });
    this.arrow = new THREE.Mesh(arrowGeometry, arrowMaterial);
    this.arrow.position.set(0, SHOOTER_Y + 1, 0);
    this.arrow.rotation.z = Math.PI; // Point upward

    // Create next bubble
    this.loadNextBubble();
  }

  updatePreview(color) {
    const previewElement = document.getElementById('next-bubble-preview');
    if (previewElement) {
      const colorHex = '#' + color.toString(16).padStart(6, '0');
      previewElement.style.backgroundColor = colorHex;
      console.log("Updated preview color to:", colorHex); // Debug log
    } else {
      console.warn("Preview element not found"); // Debug log
    }
  }

  loadNextBubble() {
    const color = COLORS[Math.floor(Math.random() * COLORS.length)];
    this.nextBubble = new Bubble(color, new THREE.Vector3(0, SHOOTER_Y + 1.2, 0));
    this.updatePreview(color);
  }

  shoot() {
    if (this.nextBubble && !this.nextBubble.isMoving) {
      const angle = this.arrow.rotation.z - Math.PI;
      this.nextBubble.velocity.set(
        Math.sin(angle) * SHOOT_SPEED,
        Math.cos(angle) * SHOOT_SPEED,
        0
      );
      this.nextBubble.isMoving = true;
      const shotBubble = this.nextBubble;

      // Load next bubble after shooting
      this.loadNextBubble();

      return shotBubble;
    }
    return null;
  }

  rotateToPoint(x, y) {
    const angle = Math.atan2(x, y - SHOOTER_Y);
    // Limit rotation to prevent shooting downward
    const limitedAngle = Math.max(-Math.PI / 3, Math.min(Math.PI / 3, angle));
    this.arrow.rotation.z = Math.PI + limitedAngle;
    return limitedAngle;
  }
}

const BubbleGame = {
  mounted() {
    console.log("BubbleGame hook mounted");
    try {
      if (!window.THREE) {
        console.error("Three.js not found!");
        return;
      }

      this.setupThreeJs();
      this.createScene();
      this.createLights();
      this.createBubbles();
      this.createShooter();
      this.setupControls();
      this.animate();

      // Initialize the preview color
      const previewElement = document.getElementById('next-bubble-preview');
      if (previewElement && this.shooter && this.shooter.nextBubble) {
        const colorHex = '#' + this.shooter.nextBubble.color.toString(16).padStart(6, '0');
        previewElement.style.backgroundColor = colorHex;
      }

      this.boundResizeHandler = () => this.handleResize();
      window.addEventListener('resize', this.boundResizeHandler);

      console.log("BubbleGame initialization complete");
    } catch (error) {
      console.error("Error initializing BubbleGame:", error);
    }
  },

  destroyed() {
    console.log("BubbleGame hook destroyed");
    try {
      window.removeEventListener('resize', this.boundResizeHandler);
      if (this.renderer) {
        this.renderer.dispose();
      }
      if (this.scene) {
        this.scene.clear();
      }
      // Clean up all bubbles
      if (this.bubbles) {
        this.bubbles.forEach(bubble => {
          if (bubble.mesh) {
            bubble.mesh.geometry.dispose();
            bubble.mesh.material.dispose();
          }
        });
      }
    } catch (error) {
      console.error("Error cleaning up BubbleGame:", error);
    }
  },

  setupThreeJs() {
    console.log("Setting up Three.js");
    this.scene = new THREE.Scene();

    const canvas = this.el.querySelector('#bubble-game-canvas');
    console.log("Canvas element:", canvas);

    const width = window.innerWidth;
    const height = window.innerHeight;

    this.camera = new THREE.PerspectiveCamera(
      75,
      width / height,
      0.1,
      1000
    );

    this.renderer = new THREE.WebGLRenderer({
      canvas,
      antialias: true,
      alpha: true
    });

    this.renderer.setSize(width, height);
    this.renderer.setPixelRatio(window.devicePixelRatio);

    this.camera.position.z = 10;
    console.log("Three.js setup complete");
  },

  createScene() {
    // Add background
    this.scene.background = new THREE.Color(0x1a1a1a);

    // Add grid for visual reference
    const gridHelper = new THREE.GridHelper(20, 20);
    gridHelper.rotation.x = Math.PI / 2;
    this.scene.add(gridHelper);
  },

  createLights() {
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
    this.scene.add(ambientLight);

    const pointLight = new THREE.PointLight(0xffffff, 1);
    pointLight.position.set(10, 10, 10);
    this.scene.add(pointLight);
  },

  createBubbles() {
    this.bubbles = [];

    for (let row = 0; row < ROWS; row++) {
      for (let col = 0; col < COLS; col++) {
        const x = (col - COLS / 2) * (BUBBLE_RADIUS * 2.1);
        const y = (ROWS - row) * (BUBBLE_RADIUS * 1.8);
        const color = COLORS[Math.floor(Math.random() * COLORS.length)];

        const bubble = new Bubble(color, new THREE.Vector3(x, y, 0));
        this.scene.add(bubble.mesh);
        this.bubbles.push(bubble);
      }
    }
  },

  createShooter() {
    this.shooter = new Shooter();
    this.scene.add(this.shooter.base);
    this.scene.add(this.shooter.arrow);
    this.scene.add(this.shooter.nextBubble.mesh);
  },

  setupControls() {
    this.raycaster = new THREE.Raycaster();
    this.mouse = new THREE.Vector2();

    // Mouse move for aiming
    this.el.addEventListener('mousemove', (event) => {
      const rect = this.renderer.domElement.getBoundingClientRect();
      const x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
      const y = ((event.clientY - rect.top) / rect.height) * 2 - 1;

      // Convert screen coordinates to world coordinates
      const worldX = x * 10;
      const worldY = y * 10;

      this.shooter.rotateToPoint(worldX, worldY);
    });

    // Click to shoot
    this.el.addEventListener('click', () => {
      const shotBubble = this.shooter.shoot();
      if (shotBubble) {
        this.scene.add(shotBubble.mesh);
        this.movingBubble = shotBubble;
      }
    });
  },

  findSnapPosition(bubble) {
    const pos = bubble.mesh.position;
    let bestDistance = Infinity;
    let bestPosition = null;

    // Check all possible grid positions
    for (let row = 0; row < ROWS; row++) {
      for (let col = 0; col < COLS; col++) {
        const x = (col - COLS / 2) * (BUBBLE_RADIUS * 2.1);
        const y = (ROWS - row) * (BUBBLE_RADIUS * 1.8);

        // Offset every other row
        const offsetX = row % 2 === 0 ? 0 : BUBBLE_RADIUS;

        const gridPos = new THREE.Vector3(x + offsetX, y, 0);
        const distance = pos.distanceTo(gridPos);

        // Check if position is empty
        const isOccupied = this.bubbles.some(b =>
          b.mesh.position.distanceTo(gridPos) < BUBBLE_RADIUS * 0.5
        );

        if (!isOccupied && distance < bestDistance) {
          bestDistance = distance;
          bestPosition = gridPos;
        }
      }
    }

    return bestPosition;
  },

  updateMovingBubble() {
    if (!this.movingBubble) return;

    const bubble = this.movingBubble;
    const pos = bubble.mesh.position;

    // Update position
    pos.add(bubble.velocity);

    // Check wall collisions
    if (pos.x < -COLS * BUBBLE_RADIUS || pos.x > COLS * BUBBLE_RADIUS) {
      bubble.velocity.x *= -1;
    }

    // Check ceiling collision
    if (pos.y > ROWS * BUBBLE_RADIUS * 1.8) {
      this.snapBubble(bubble);
      return;
    }

    // Check collision with other bubbles
    for (const otherBubble of this.bubbles) {
      const distance = pos.distanceTo(otherBubble.mesh.position);
      if (distance < BUBBLE_RADIUS * 2) {
        this.snapBubble(bubble);
        return;
      }
    }
  },

  snapBubble(bubble) {
    const snapPos = this.findSnapPosition(bubble);
    if (snapPos) {
      bubble.mesh.position.copy(snapPos);
      bubble.isMoving = false;
      this.bubbles.push(bubble);
      this.movingBubble = null;

      // Check for matches
      const matches = this.findMatchingBubbles(bubble);
      if (matches.length >= 3) {
        this.popBubbles(matches);
      }

      // Check for game over (bubbles too low)
      if (this.checkGameOver()) {
        alert("Game Over!");
        this.resetGame();
      }
    }
  },

  checkGameOver() {
    return this.bubbles.some(bubble =>
      bubble.mesh.position.y < SHOOTER_Y + 2
    );
  },

  resetGame() {
    // Remove all bubbles
    for (const bubble of this.bubbles) {
      this.scene.remove(bubble.mesh);
      bubble.mesh.geometry.dispose();
      bubble.mesh.material.dispose();
    }
    this.bubbles = [];

    // Recreate initial bubbles
    this.createBubbles();
  },

  handleResize() {
    const width = window.innerWidth;
    const height = window.innerHeight;

    this.camera.aspect = width / height;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(width, height);
  },

  animate() {
    if (!this.renderer || !this.scene || !this.camera) {
      console.error("Required Three.js components not initialized");
      return;
    }

    try {
      requestAnimationFrame(() => this.animate());

      if (this.movingBubble) {
        this.updateMovingBubble();
      }

      this.renderer.render(this.scene, this.camera);
    } catch (error) {
      console.error("Error in animation loop:", error);
    }
  },

  findMatchingBubbles(bubble, matches = new Set()) {
    matches.add(bubble);

    // Get all neighbors
    const neighbors = this.getNeighbors(bubble);

    // For each neighbor of the same color
    for (const neighbor of neighbors) {
      if (!matches.has(neighbor) && neighbor.color === bubble.color) {
        // Recursively find matches
        this.findMatchingBubbles(neighbor, matches);
      }
    }

    return Array.from(matches);
  },

  getNeighbors(bubble) {
    const neighbors = [];
    const pos = bubble.mesh.position;

    // Check all bubbles for neighbors
    for (const other of this.bubbles) {
      if (other === bubble) continue;

      const distance = pos.distanceTo(other.mesh.position);
      // Use a slightly larger radius for matching to make it more forgiving
      if (distance < BUBBLE_RADIUS * 2.5) {
        neighbors.push(other);
      }
    }

    return neighbors;
  },

  popBubbles(bubbles) {
    // Remove the bubbles from the scene and the bubbles array
    for (const bubble of bubbles) {
      this.scene.remove(bubble.mesh);
      bubble.mesh.geometry.dispose();
      bubble.mesh.material.dispose();
      const index = this.bubbles.indexOf(bubble);
      if (index > -1) {
        this.bubbles.splice(index, 1);
      }
    }

    // After popping, check for floating bubbles
    this.removeFloatingBubbles();
  },

  removeFloatingBubbles() {
    // Find all bubbles that are still connected to the top
    const anchored = new Set();

    // Start from all bubbles in the top row
    for (const bubble of this.bubbles) {
      if (bubble.mesh.position.y >= (ROWS - 1) * BUBBLE_RADIUS * 1.8) {
        this.findConnectedBubbles(bubble, anchored);
      }
    }

    // Remove all bubbles that aren't anchored
    const floating = this.bubbles.filter(bubble => !anchored.has(bubble));
    if (floating.length > 0) {
      this.popBubbles(floating);
    }
  },

  findConnectedBubbles(bubble, connected = new Set()) {
    connected.add(bubble);

    // Get all neighbors
    const neighbors = this.getNeighbors(bubble);

    // For each unvisited neighbor
    for (const neighbor of neighbors) {
      if (!connected.has(neighbor)) {
        this.findConnectedBubbles(neighbor, connected);
      }
    }

    return connected;
  }
};

export default BubbleGame;