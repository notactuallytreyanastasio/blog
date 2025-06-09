import GameAnimations from "./hooks/game_animations";
import BezierTriangles from "./hooks/bezier_triangles";
import MtaBusMap from "./hooks/mta_bus_map";
import BubbleGame from "./hooks/bubble_game";

const PostExpander = {
  mounted() {
    this.handleEvent("toggle_post", ({slug}) => {
      const postCard = document.getElementById(`post-${slug}`);
      const content = document.getElementById(`content-${slug}`);
      
      if (postCard && content) {
        postCard.classList.toggle('expanded');
      }
    });
  }
};

const AsciinemaPlayer = {
  mounted() {
    const element = this.el;
    const src = element.dataset.src;
    
    console.log('AsciinemaPlayer mounted. Element:', element);
    console.log('Dataset:', element.dataset);
    console.log('Src:', src);
    
    const options = {
      autoPlay: element.dataset.autoplay === "true",
      loop: element.dataset.loop === "true",
      startAt: element.dataset.startAt ? parseFloat(element.dataset.startAt) : 0,
      speed: element.dataset.speed ? parseFloat(element.dataset.speed) : 1,
      theme: element.dataset.theme || "asciinema",
      fit: element.dataset.fit || "width",
      fontSize: element.dataset.fontSize || "small"
    };

    // Check if asciinema player is loaded
    if (typeof window.AsciinemaPlayer !== 'undefined') {
      console.log('Creating asciinema player with:', { src, options });
      window.AsciinemaPlayer.create(src, element, options);
    } else {
      console.error('Asciinema player library not loaded. Available on window:', Object.keys(window).filter(k => k.toLowerCase().includes('asciinema')));
    }
  }
};

export { AsciinemaPlayer };

export default {
  GameAnimations,
  BezierTriangles,
  MtaBusMap,
  BubbleGame,
  PostExpander,
  AsciinemaPlayer
};