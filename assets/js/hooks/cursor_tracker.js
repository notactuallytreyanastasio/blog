const CursorTracker = {
  mounted() {
    this.handleMouseMove = (e) => {
      // Get the mouse position relative to the viewport
      const x = e.clientX;
      const y = e.clientY;

      // Get the visualization container
      const visualizationContainer = this.el.querySelector('.relative.h-64.border');

      if (visualizationContainer) {
        // Get the bounding rectangle of the visualization container
        const rect = visualizationContainer.getBoundingClientRect();

        // Calculate the position relative to the visualization container
        const relativeX = x - rect.left;
        const relativeY = y - rect.top;

        // Only send the event if the cursor is within the visualization area
        // or send viewport coordinates for the main display and relative coordinates for visualization
        this.pushEvent("mousemove", {
          x: x,
          y: y,
          relativeX: relativeX,
          relativeY: relativeY,
          inVisualization: relativeX >= 0 && relativeX <= rect.width &&
                          relativeY >= 0 && relativeY <= rect.height
        });
      } else {
        // Fallback if visualization container is not found
        this.pushEvent("mousemove", { x: x, y: y });
      }
    };
    console.log("Mounted and have position")
    // Add the event listener to the document
    document.addEventListener("mousemove", this.handleMouseMove);
  },

  destroyed() {
    // Remove the event listener when the element is removed
    document.removeEventListener("mousemove", this.handleMouseMove);
  }
};

export default CursorTracker;