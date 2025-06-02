import BreakoutGame from "./hooks/breakout_game";
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

export default {
  BreakoutGame,
  GameAnimations,
  BezierTriangles,
  MtaBusMap,
  BubbleGame,
  PostExpander
};