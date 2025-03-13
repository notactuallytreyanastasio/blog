tags: tech,hacking,elxiir,phoenix,liveview,ai
## A series of prompts: making a weird pong game, only with AI
I wanted to make something the other day and couldn't get any ideas.

I started thinking about infinite games and ended up at playing pong against a wall.

I figured I would implement it and vibe code something out, making it more absurd as I went.

This is an examination of all my prompts as I went along.

## Getting Started
I began with a vague guideline like I always do

> Let's implement a new LiveView.

> I want to play pong. Except, for now, let's make it so I am just playing against a wall. I simply bounce the ball off the wall infinitely. I want to start here, and in the future, in order to move the paddles, I am going to build a consensus model between visitors to the webpage who will be "voting" on an action (move up, move down) and determining what happens for the paddles next move. 

This is lofty. A consensus model isn't going to be the first thing I get.
But I wanted the AI to _think big_ -- this is often helpful when trying to get it to do more complex projects, in my experience.

From this, we get back a summary and a working single-paddle pong implementation with basic black and white graphics.

The response:

> I've implemented a basic Pong game where the ball bounces off all walls. Here's how it works:

> Game State: The game maintains state for the ball position (x, y) and velocity (dx, dy), as well as the game board dimensions.

> Game Loop: I've set up a timer that runs at 60 frames per second using `:timer.send_interval/2`. On each tick, we update the ball position and check for collisions.

> Physics: When the ball hits any wall, it bounces by reversing its velocity in the appropriate axis.

> Rendering: The game is rendered using HTML and CSS, with the ball as a white circle on a dark background.

> This lays the groundwork for the future enhancements you mentioned about adding paddles and implementing the consensus voting mechanism.

> To test it out, start your Phoenix server and navigate to /pong in your browser. You should see the ball bouncing around the game board.

> Q1: Would you like to make any adjustments to the ball's speed or the game board dimensions to improve gameplay?
> Q2: Should we add some visual elements like a paddle on one side to represent the future multiplayer aspect, even if it's not functional yet?
> Q3: How would you like to structure the future consensus voting mechanism - should users vote directly on paddle positions or on movement directions (up/down)?
