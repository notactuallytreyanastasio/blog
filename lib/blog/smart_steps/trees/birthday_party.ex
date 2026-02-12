defmodule Blog.SmartSteps.Trees.BirthdayParty do
  alias Blog.SmartSteps.Types.{ScenarioTree, Scenario, Choice}

  def tree do
    %ScenarioTree{
      id: "birthday-party",
      title: "The Birthday Party",
      description:
        "Your friend invited you to their birthday party. When you arrive, the music is loud, balloons everywhere, and 20 kids are running around. Can you find a way to enjoy the party?",
      theme: :sensory_overload,
      age_range: "6-12",
      estimated_minutes: 10,
      start_scenario_id: "birthday-party-start",
      scenarios: %{
        "birthday-party-start" => %Scenario{
          id: "birthday-party-start",
          tree_id: "birthday-party",
          location: "Front Door",
          location_category: :birthday_party,
          theme: :sensory_overload,
          level: 1,
          title: "Arriving at the Party",
          description:
            "Your mom drives you to your friend Alex's birthday party. As you walk up to the front door, you can already hear loud music thumping. The door opens and you see balloons everywhere, streamers hanging from the ceiling, and about 20 kids running around, yelling and laughing. The smell of pizza and cake mixes with the popping of balloon animals.",
          choices: [
            %Choice{
              id: "bp-c1-go-in",
              text: "Take a deep breath and go inside",
              next_scenario_id: "birthday-party-inside",
              risk_level: :medium,
              consequence_hint: "A lot of sensory input at once"
            },
            %Choice{
              id: "bp-c1-parent",
              text: "Ask your parent to come inside with you for a few minutes",
              next_scenario_id: "birthday-party-with-parent",
              risk_level: :low,
              consequence_hint: "Extra support"
            },
            %Choice{
              id: "bp-c1-quiet",
              text: "Ask if there is a quieter room to start in",
              next_scenario_id: "birthday-party-quiet-room",
              risk_level: :low,
              consequence_hint: "Find a calmer space"
            },
            %Choice{
              id: "bp-c1-leave",
              text: "Tell your parent you want to go home",
              next_scenario_id: "birthday-party-leave-early",
              risk_level: :medium,
              consequence_hint: "Avoid the situation entirely"
            }
          ],
          image_color: "#FFEE58"
        },
        "birthday-party-inside" => %Scenario{
          id: "birthday-party-inside",
          tree_id: "birthday-party",
          location: "Living Room",
          location_category: :birthday_party,
          theme: :sensory_overload,
          level: 2,
          title: "Into the Chaos",
          description:
            "You walk in. The noise hits you like a wall. Kids are screaming, music is blasting, and someone just popped a balloon right next to you. BANG! Your heart is racing. Alex waves from across the room and yells, 'You made it!' A group of kids you do not know are playing a game nearby.",
          choices: [
            %Choice{
              id: "bp-c2-alex",
              text: "Wave back at Alex and walk over to say happy birthday",
              next_scenario_id: "birthday-party-find-alex",
              risk_level: :low,
              consequence_hint: "Focus on your friend"
            },
            %Choice{
              id: "bp-c2-overwhelmed",
              text: "The balloon pop was too much. Cover your ears and stand still.",
              next_scenario_id: "birthday-party-overwhelmed",
              risk_level: :high,
              consequence_hint: "Sensory overload building"
            },
            %Choice{
              id: "bp-c2-corner",
              text: "Find a corner of the room away from the loudest kids",
              next_scenario_id: "birthday-party-corner",
              risk_level: :medium,
              consequence_hint: "Find some space"
            }
          ],
          image_color: "#9b59b6"
        },
        "birthday-party-with-parent" => %Scenario{
          id: "birthday-party-with-parent",
          tree_id: "birthday-party",
          location: "Entryway",
          location_category: :birthday_party,
          theme: :sensory_overload,
          level: 2,
          title: "A Safe Start",
          description:
            "Your parent comes in with you. They help you find Alex's mom and say hello. Alex's mom shows you where the quieter activities are: a craft table in the dining room and some books in the den. Your parent stays for a few minutes until you feel ready.",
          choices: [
            %Choice{
              id: "bp-c3-crafts",
              text: "Go to the craft table where it is calmer",
              next_scenario_id: "birthday-party-crafts",
              risk_level: :low,
              consequence_hint: "A comfortable starting point"
            },
            %Choice{
              id: "bp-c3-ready",
              text: "Tell your parent you are okay now and go find Alex",
              next_scenario_id: "birthday-party-find-alex",
              risk_level: :low,
              consequence_hint: "Feeling braver"
            }
          ],
          image_color: "#42A5F5"
        },
        "birthday-party-quiet-room" => %Scenario{
          id: "birthday-party-quiet-room",
          tree_id: "birthday-party",
          location: "Dining Room",
          location_category: :birthday_party,
          theme: :sensory_overload,
          level: 2,
          title: "The Quiet Side",
          description:
            "Alex's mom takes you to the dining room where it is much calmer. There are coloring supplies and a craft project set up. Two other kids are there making friendship bracelets. 'You can hang out here as long as you want,' Alex's mom says with a kind smile.",
          choices: [
            %Choice{
              id: "bp-c4-bracelet",
              text: "Sit down and start making a bracelet. Ask the other kids what colors they are using.",
              next_scenario_id: "birthday-party-crafts",
              risk_level: :low,
              consequence_hint: "Ease in gently"
            },
            %Choice{
              id: "bp-c4-peek",
              text: "Do crafts for a bit, then peek into the party when you feel ready",
              next_scenario_id: "birthday-party-peek",
              risk_level: :low,
              consequence_hint: "Gradual approach"
            }
          ],
          image_color: "#66BB6A"
        },
        "birthday-party-leave-early" => %Scenario{
          id: "birthday-party-leave-early",
          tree_id: "birthday-party",
          location: "Car",
          location_category: :car,
          theme: :sensory_overload,
          level: 2,
          title: "Going Home",
          description:
            "Your parent says, 'Okay, but can we try for just ten minutes first?' You shake your head. You get back in the car. On the ride home, you feel relieved but also sad that you missed Alex's party. Alex might wonder why you left.",
          choices: [
            %Choice{
              id: "bp-c5-card",
              text: "Ask your parent if you can make Alex a card and bring it to school Monday",
              next_scenario_id: "birthday-party-card-end",
              risk_level: :low,
              consequence_hint: "Still show you care"
            },
            %Choice{
              id: "bp-c5-nothing",
              text: "Say nothing and stare out the window",
              next_scenario_id: "birthday-party-missed-end",
              risk_level: :medium,
              consequence_hint: "Avoiding the feelings"
            }
          ],
          image_color: "#42A5F5"
        },
        "birthday-party-find-alex" => %Scenario{
          id: "birthday-party-find-alex",
          tree_id: "birthday-party",
          location: "Living Room",
          location_category: :birthday_party,
          theme: :sensory_overload,
          level: 3,
          title: "Finding Your Friend",
          description:
            "You walk over to Alex. 'Happy birthday!' you say, and hand over the present. Alex grins. 'Thanks! We are about to play musical chairs. Do you want to play?' The music will be loud for that game, and there will be a lot of bumping and pushing to get chairs.",
          choices: [
            %Choice{
              id: "bp-c6-play",
              text: "Say yes and play the game",
              next_scenario_id: "birthday-party-game",
              risk_level: :medium,
              consequence_hint: "Challenge yourself"
            },
            %Choice{
              id: "bp-c6-watch",
              text: "Say, 'I will watch this one! Can I play the next game?'",
              next_scenario_id: "birthday-party-watch",
              risk_level: :low,
              consequence_hint: "Pace yourself"
            },
            %Choice{
              id: "bp-c6-suggest",
              text: "Ask Alex if there are any other games too",
              next_scenario_id: "birthday-party-other-game",
              risk_level: :low,
              consequence_hint: "Find an alternative"
            }
          ],
          image_color: "#FFEE58"
        },
        "birthday-party-overwhelmed" => %Scenario{
          id: "birthday-party-overwhelmed",
          tree_id: "birthday-party",
          location: "Living Room",
          location_category: :birthday_party,
          theme: :sensory_overload,
          level: 3,
          title: "Everything Is Too Much",
          description:
            "You stand frozen near the door with your ears covered. Kids rush past you. The lights, sounds, and smells are swirling together. You feel dizzy and your eyes are getting watery. A parent volunteer notices you standing there and kneels down. 'Hey, are you okay? Do you need some help?'",
          choices: [
            %Choice{
              id: "bp-c7-yes-help",
              text: "Nod and whisper, 'It is too loud.'",
              next_scenario_id: "birthday-party-rescue",
              risk_level: :low,
              consequence_hint: "Accept the help"
            },
            %Choice{
              id: "bp-c7-shutdown",
              text: "You cannot speak. Tears start falling.",
              next_scenario_id: "birthday-party-shutdown-end",
              risk_level: :critical,
              consequence_hint: "Sensory shutdown"
            }
          ],
          image_color: "#EC407A"
        },
        "birthday-party-corner" => %Scenario{
          id: "birthday-party-corner",
          tree_id: "birthday-party",
          location: "Living Room Corner",
          location_category: :birthday_party,
          theme: :sensory_overload,
          level: 3,
          title: "Your Safe Spot",
          description:
            "You find a spot near the bookshelf where it is a little calmer. From here you can see the party without being in the middle of it. You watch the kids play and start to feel your heartbeat slow down. After a few minutes, a kid named Sam walks over. 'Hey, do you want to come play?'",
          choices: [
            %Choice{
              id: "bp-c8-join",
              text: "Say, 'Sure! What are you playing?'",
              next_scenario_id: "birthday-party-new-friend",
              risk_level: :low,
              consequence_hint: "Ready to join in"
            },
            %Choice{
              id: "bp-c8-not-yet",
              text: "Say, 'Maybe in a minute. I am just getting used to how loud it is.'",
              next_scenario_id: "birthday-party-honest",
              risk_level: :low,
              consequence_hint: "Honest self-advocacy"
            }
          ],
          image_color: "#42A5F5"
        },
        "birthday-party-crafts" => %Scenario{
          id: "birthday-party-crafts",
          tree_id: "birthday-party",
          location: "Dining Room",
          location_category: :birthday_party,
          theme: :sensory_overload,
          level: 3,
          title: "Crafting Together",
          description:
            "You sit down at the craft table and start making a friendship bracelet. The two kids next to you are nice. One of them, Jamie, shows you a cool pattern. 'Want me to teach you?' Jamie asks. This part of the party feels manageable. After a while, someone announces it is cake time.",
          choices: [
            %Choice{
              id: "bp-c9-cake",
              text: "Go to the main room for cake and singing",
              next_scenario_id: "birthday-party-cake",
              risk_level: :medium,
              consequence_hint: "The group will sing loudly"
            },
            %Choice{
              id: "bp-c9-wait",
              text: "Ask Jamie if you can go together, so you have someone to sit with",
              next_scenario_id: "birthday-party-cake-buddy",
              risk_level: :low,
              consequence_hint: "Use the buddy system"
            }
          ],
          image_color: "#66BB6A"
        },
        "birthday-party-peek" => %Scenario{
          id: "birthday-party-peek",
          tree_id: "birthday-party",
          location: "Doorway",
          location_category: :birthday_party,
          theme: :sensory_overload,
          level: 3,
          title: "Peeking In",
          description:
            "After doing crafts for a while, you peek into the party room from the doorway. The game is over now and kids are sitting down. It seems a little calmer. Alex sees you and runs over. 'There you are! Come sit with me. We are about to have cake!'",
          choices: [
            %Choice{
              id: "bp-c10-join-alex",
              text: "Go sit with Alex for cake time",
              next_scenario_id: "birthday-party-cake-buddy",
              risk_level: :low,
              consequence_hint: "Your friend saved you a spot"
            }
          ],
          image_color: "#66BB6A"
        },
        "birthday-party-game" => %Scenario{
          id: "birthday-party-game",
          tree_id: "birthday-party",
          location: "Living Room",
          location_category: :birthday_party,
          theme: :sensory_overload,
          level: 4,
          title: "Musical Chairs",
          description:
            "The music blasts and everyone runs around the chairs. A kid bumps into you hard. When the music stops, you are the first one out. The bumping and the loud music were a lot. You feel upset about getting out first.",
          choices: [
            %Choice{
              id: "bp-c11-laugh",
              text: "Shrug and laugh. 'I will get a chair next time!'",
              next_scenario_id: "birthday-party-good-sport-end",
              risk_level: :low,
              consequence_hint: "Good sportsmanship"
            },
            %Choice{
              id: "bp-c11-upset",
              text: "Feel really frustrated and stomp away from the game",
              next_scenario_id: "birthday-party-frustrated-end",
              risk_level: :high,
              consequence_hint: "Frustration takes over"
            }
          ],
          image_color: "#FFEE58"
        },
        "birthday-party-watch" => %Scenario{
          id: "birthday-party-watch",
          tree_id: "birthday-party",
          location: "Living Room",
          location_category: :birthday_party,
          theme: :sensory_overload,
          level: 4,
          title: "Watching and Waiting",
          description:
            "You sit on the couch and watch the game. It is actually kind of fun to watch! You cheer when Alex wins a round. When the next game is a quieter scavenger hunt, Alex says, 'This one is perfect for you! You are great at finding things.' You join in and have a really good time.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You paced yourself by watching first, then joining a game that felt better for you. How does it feel to choose which activities work best for you instead of forcing yourself into everything?",
          learning_points: [
            "You do not have to do every activity at a party to have fun",
            "Watching first helps you figure out what you are comfortable with",
            "Friends understand when you skip one game and join the next",
            "Knowing your limits is a superpower, not a weakness"
          ]
        },
        "birthday-party-other-game" => %Scenario{
          id: "birthday-party-other-game",
          tree_id: "birthday-party",
          location: "Backyard",
          location_category: :birthday_party,
          theme: :sensory_overload,
          level: 4,
          title: "A Better Fit",
          description:
            "Alex says, 'Oh yeah! There is a scavenger hunt in the backyard later, and my mom set up a craft table in the other room.' You decide to check out the backyard. It is open and quieter. A few kids are already out here kicking a ball around. The fresh air feels great.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You asked about other options instead of forcing yourself into a game that was too intense. Why is it smart to look for alternatives instead of just saying no to everything?",
          learning_points: [
            "Asking about options is great self-advocacy",
            "Parties have many activities; you can pick what works for you",
            "Going outside or to a quieter space is always an option",
            "You can have fun in your own way at a party"
          ]
        },
        "birthday-party-rescue" => %Scenario{
          id: "birthday-party-rescue",
          tree_id: "birthday-party",
          location: "Den",
          location_category: :birthday_party,
          theme: :sensory_overload,
          level: 4,
          title: "A Helping Hand",
          description:
            "The parent volunteer takes you to a quiet den off the hallway. 'Take your time,' they say. 'Would you like some water?' After a few minutes of quiet, you feel much better. The volunteer asks if you want to go back to the party or stay here for a bit.",
          choices: [
            %Choice{
              id: "bp-c12-go-back",
              text: "Go back to the party, but ask to stay near the quieter areas",
              next_scenario_id: "birthday-party-crafts",
              risk_level: :low,
              consequence_hint: "Ready to try again"
            },
            %Choice{
              id: "bp-c12-stay",
              text: "Stay in the den. Maybe a friend can visit you here.",
              next_scenario_id: "birthday-party-den-end",
              risk_level: :medium,
              consequence_hint: "Take what you need"
            }
          ],
          image_color: "#42A5F5"
        },
        "birthday-party-shutdown-end" => %Scenario{
          id: "birthday-party-shutdown-end",
          tree_id: "birthday-party",
          location: "Living Room",
          location_category: :birthday_party,
          theme: :sensory_overload,
          level: 4,
          title: "Sensory Shutdown",
          description:
            "Everything becomes a blur. The adult calls your parent, who comes to pick you up. You spend the car ride home feeling exhausted and upset. Your parent says, 'It is okay. We will figure out a plan for next time.' You missed the party, but you are safe now.",
          choices: [],
          image_color: "#9b59b6",
          is_game_over: true,
          outcome_type: :severe,
          discussion_prompt:
            "The party was too much all at once, and you did not have the tools you needed. What could you and your parent plan BEFORE the next party so this does not happen again?",
          learning_points: [
            "A plan before the party can prevent sensory shutdown",
            "Headphones, a fidget, or a buddy can be great party tools",
            "It is okay to arrive late or leave early if you need to",
            "Telling a grown-up 'it is too loud' BEFORE a shutdown is key"
          ]
        },
        "birthday-party-new-friend" => %Scenario{
          id: "birthday-party-new-friend",
          tree_id: "birthday-party",
          location: "Living Room",
          location_category: :birthday_party,
          theme: :sensory_overload,
          level: 4,
          title: "A New Connection",
          description:
            "Sam takes you to a group building a tower out of blocks. It is a little calmer here. You end up having a great time building together. Sam says, 'You are really good at this! Do you want to sit together at cake time?' You made a new friend by finding your own pace at the party.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You found a comfortable spot, and someone came to you. Sometimes being yourself is the best way to make friends. How did finding your own space help?",
          learning_points: [
            "You do not have to be in the middle of everything to make friends",
            "Finding your comfortable spot can attract the right people",
            "Taking time to adjust is okay and can lead to good things",
            "Being yourself is the best way to find real friends"
          ]
        },
        "birthday-party-honest" => %Scenario{
          id: "birthday-party-honest",
          tree_id: "birthday-party",
          location: "Living Room Corner",
          location_category: :birthday_party,
          theme: :sensory_overload,
          level: 4,
          title: "Honest About Needs",
          description:
            "Sam nods and says, 'Yeah, it is pretty loud! I will come check on you in a bit.' A few minutes later, Sam comes back with two juice boxes. You sit together and watch the games from the side. Eventually you both join in a quieter game. Being honest about needing time was the best choice you made all day.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You told Sam you needed a minute, and Sam completely understood. Why is it important to be honest about what you need? How did it feel when Sam was kind about it?",
          learning_points: [
            "Being honest about your needs helps others know how to support you",
            "Most people are kind when you explain what you need",
            "Self-advocacy means speaking up for yourself in a calm way",
            "You can join the fun at your own pace"
          ]
        },
        "birthday-party-cake" => %Scenario{
          id: "birthday-party-cake",
          tree_id: "birthday-party",
          location: "Dining Room",
          location_category: :birthday_party,
          theme: :sensory_overload,
          level: 4,
          title: "Happy Birthday Singing",
          description:
            "Everyone crowds around the table. Someone turns off the lights for the candles. Then twenty kids start singing Happy Birthday at the top of their lungs. It is very loud and very crowded. But it only lasts about thirty seconds. When the lights come back on and cake is served, you realize you made it through!",
          choices: [],
          image_color: "#FFEE58",
          is_game_over: true,
          outcome_type: :neutral,
          discussion_prompt:
            "The singing was loud and crowded, but it was short. Sometimes hard moments are over quickly. How can knowing that something will be short help you get through it?",
          learning_points: [
            "Some loud moments are short and you can get through them",
            "Counting to yourself can help during brief loud moments",
            "It is okay to cover your ears lightly during singing",
            "The reward (cake!) can be worth a short hard moment"
          ]
        },
        "birthday-party-cake-buddy" => %Scenario{
          id: "birthday-party-cake-buddy",
          tree_id: "birthday-party",
          location: "Dining Room",
          location_category: :birthday_party,
          theme: :sensory_overload,
          level: 4,
          title: "Cake with a Friend",
          description:
            "You walk into the dining room with your friend by your side. They save you a seat at the end of the table, where it is a little less crowded. When everyone sings, you cover one ear with your hand and it helps. The cake is delicious. Your friend smiles at you and you smile back. You did it!",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "Having a buddy made the hardest part of the party easier. Who are the people in your life who help you feel safe in hard situations? How can you ask them for help?",
          learning_points: [
            "Having a buddy at events makes hard things easier",
            "Asking someone to sit with you is a great strategy",
            "Small coping tricks like covering one ear can help a lot",
            "Friends who understand your needs are wonderful allies"
          ]
        },
        "birthday-party-card-end" => %Scenario{
          id: "birthday-party-card-end",
          tree_id: "birthday-party",
          location: "Home",
          location_category: :home,
          theme: :sensory_overload,
          level: 3,
          title: "A Kind Gesture",
          description:
            "At home, you make a beautiful card for Alex with drawings and stickers. You write, 'Sorry I could not stay at your party. Happy Birthday!' On Monday, Alex loves the card and says, 'Want to have a playdate this weekend? Just us?' That sounds much better.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :neutral,
          discussion_prompt:
            "You could not handle the party, but you found another way to show your friend you care. What are some ways to be a good friend even when parties are hard for you?",
          learning_points: [
            "There are many ways to celebrate a friend besides a big party",
            "A thoughtful card or gesture can mean a lot",
            "Smaller get-togethers can be just as meaningful",
            "Leaving a party does not mean losing a friendship"
          ]
        },
        "birthday-party-missed-end" => %Scenario{
          id: "birthday-party-missed-end",
          tree_id: "birthday-party",
          location: "Home",
          location_category: :home,
          theme: :sensory_overload,
          level: 3,
          title: "Missed Opportunity",
          description:
            "You go home and spend the afternoon alone. On Monday, all the kids at school talk about how fun the party was. Alex asks, 'Where did you go?' You do not know what to say. You feel left out and wish you had tried a little longer or at least explained.",
          choices: [],
          image_color: "#42A5F5",
          is_game_over: true,
          outcome_type: :negative,
          discussion_prompt:
            "Leaving without trying felt safer in the moment, but it led to feeling left out later. What is one small thing you could try next time before deciding to leave?",
          learning_points: [
            "Avoiding everything can lead to missing out on good things",
            "Trying for a short time before deciding to leave is a good goal",
            "Telling your friend why you left helps them understand",
            "Making a plan with your parent before the event can help"
          ]
        },
        "birthday-party-good-sport-end" => %Scenario{
          id: "birthday-party-good-sport-end",
          tree_id: "birthday-party",
          location: "Living Room",
          location_category: :birthday_party,
          theme: :sensory_overload,
          level: 5,
          title: "Good Sport",
          description:
            "You laugh it off and sit on the couch to watch the rest. Kids around you are impressed that you took it so well. Alex calls out, 'You will win next time!' You enjoy watching the game and cheering for friends. When cake comes, you are feeling proud that you handled the loud game AND losing. What a party!",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You played a game that was hard for you AND handled losing gracefully. That takes two different kinds of strength. Which was harder: the loud game or losing?",
          learning_points: [
            "Being a good sport is a skill everyone admires",
            "It is okay to lose. Games are about having fun together",
            "Trying something hard and then being kind about the outcome is impressive",
            "You can be proud of yourself for trying, win or lose"
          ]
        },
        "birthday-party-frustrated-end" => %Scenario{
          id: "birthday-party-frustrated-end",
          tree_id: "birthday-party",
          location: "Living Room",
          location_category: :birthday_party,
          theme: :sensory_overload,
          level: 5,
          title: "Frustration Boils Over",
          description:
            "You stomp away from the game and sit in a corner with your arms crossed. Some kids whisper. Alex looks confused and a little hurt. A parent comes over and asks if you are okay. You feel embarrassed and upset. The rest of the party feels awkward.",
          choices: [],
          image_color: "#EC407A",
          is_game_over: true,
          outcome_type: :negative,
          discussion_prompt:
            "The bumping, the noise, AND losing were all too much at once. What could you do next time you feel frustration building up instead of stomping away?",
          learning_points: [
            "It is okay to feel frustrated, but how we show it matters",
            "Walking away calmly is different from stomping away angrily",
            "If a game is too much, you can say 'I need a break' before it gets big",
            "Sensory overload plus frustration is a hard combination. Plan for it."
          ]
        },
        "birthday-party-den-end" => %Scenario{
          id: "birthday-party-den-end",
          tree_id: "birthday-party",
          location: "Den",
          location_category: :birthday_party,
          theme: :sensory_overload,
          level: 5,
          title: "A Quiet Party",
          description:
            "Alex comes to find you in the den and brings you a piece of cake. 'I am glad you came even though it was loud,' Alex says. You eat cake together in the quiet room and talk about your favorite video game. It was not the party you expected, but you still got to celebrate with your friend.",
          choices: [],
          image_color: "#42A5F5",
          is_game_over: true,
          outcome_type: :neutral,
          discussion_prompt:
            "You spent most of the party in a quiet room, but your friend came to find you. Was the party still worth going to? What would make next time easier?",
          learning_points: [
            "A party does not have to look the same for everyone",
            "True friends will come find you where you are comfortable",
            "Going to the party, even if you stay in a quiet room, matters",
            "Every time you try, you learn more about what works for you"
          ]
        }
      }
    }
  end
end
