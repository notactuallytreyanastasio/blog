defmodule Blog.SmartSteps.Trees.NewKid do
  alias Blog.SmartSteps.Types.{ScenarioTree, Scenario, Choice}

  def tree do
    %ScenarioTree{
      id: "new-kid",
      title: "The New Kid",
      description:
        "A new student sits alone at lunch. Your friends do not notice them. What will you do?",
      theme: :friendship,
      age_range: "6-12",
      estimated_minutes: 10,
      start_scenario_id: "new-kid-start",
      scenarios: %{
        "new-kid-start" => %Scenario{
          id: "new-kid-start",
          tree_id: "new-kid",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :friendship,
          level: 1,
          title: "The Empty Table",
          description:
            "You are sitting at lunch with your friends. You notice a new kid sitting all alone at the next table. They are looking down at their food and not eating. Your friend is telling a funny story, but you keep glancing at the new kid. They look really sad.",
          choices: [
            %Choice{
              id: "nk-c1-say-hi",
              text: "Walk over and say hi to the new kid",
              next_scenario_id: "new-kid-say-hi",
              risk_level: :low,
              consequence_hint: "Be brave and friendly"
            },
            %Choice{
              id: "nk-c1-tell-friends",
              text: "Tell your friends, 'Hey, that kid is all alone. Should we invite them over?'",
              next_scenario_id: "new-kid-tell-friends",
              risk_level: :low,
              consequence_hint: "Get your group involved"
            },
            %Choice{
              id: "nk-c1-keep-eating",
              text: "Keep eating and listening to your friend's story",
              next_scenario_id: "new-kid-ignore",
              risk_level: :medium,
              consequence_hint: "It is easier to do nothing"
            },
            %Choice{
              id: "nk-c1-invite",
              text: "Wave at the new kid and point to an empty seat at your table",
              next_scenario_id: "new-kid-wave",
              risk_level: :low,
              consequence_hint: "A simple gesture"
            }
          ],
          image_color: "#42A5F5"
        },
        "new-kid-say-hi" => %Scenario{
          id: "new-kid-say-hi",
          tree_id: "new-kid",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :friendship,
          level: 2,
          title: "Saying Hello",
          description:
            "You walk over to the new kid's table. 'Hi, I am [your name]. Are you new here?' The kid looks up, surprised. 'Yeah, I just moved here. I am Jordan.' Jordan seems shy but relieved that someone talked to them. 'Do you want to sit with us?' you ask, pointing to your table.",
          choices: [
            %Choice{
              id: "nk-c2-come-over",
              text: "Bring Jordan back to your table and introduce them to everyone",
              next_scenario_id: "new-kid-introduce",
              risk_level: :low,
              consequence_hint: "Include them in your group"
            },
            %Choice{
              id: "nk-c2-sit-here",
              text: "Sit with Jordan at their table for a while and chat",
              next_scenario_id: "new-kid-one-on-one",
              risk_level: :low,
              consequence_hint: "Less overwhelming for Jordan"
            }
          ],
          image_color: "#66BB6A"
        },
        "new-kid-tell-friends" => %Scenario{
          id: "new-kid-tell-friends",
          tree_id: "new-kid",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :friendship,
          level: 2,
          title: "Talking to Friends",
          description:
            "You say to your group, 'Hey, see that kid over there? They are new and all alone. Should we invite them to sit with us?' One friend says, 'Sure!' Another friend shrugs and says, 'I do not know. What if they are weird?' That was not a nice thing to say.",
          choices: [
            %Choice{
              id: "nk-c3-stand-up",
              text: "Say, 'They are not weird, they are just new. Everyone deserves a friend.'",
              next_scenario_id: "new-kid-stand-up",
              risk_level: :low,
              consequence_hint: "Stand up for what is right"
            },
            %Choice{
              id: "nk-c3-go-alone",
              text: "Ignore the rude comment and go invite the new kid yourself",
              next_scenario_id: "new-kid-say-hi",
              risk_level: :low,
              consequence_hint: "Take action anyway"
            },
            %Choice{
              id: "nk-c3-drop-it",
              text: "Drop it and go back to eating",
              next_scenario_id: "new-kid-drop-it",
              risk_level: :medium,
              consequence_hint: "Peer pressure wins"
            }
          ],
          image_color: "#FFEE58"
        },
        "new-kid-ignore" => %Scenario{
          id: "new-kid-ignore",
          tree_id: "new-kid",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :friendship,
          level: 2,
          title: "Looking Away",
          description:
            "You turn back to your friends and laugh at the story. But you keep glancing over at the new kid. They have stopped even pretending to eat. They are just sitting there, staring at the table. Lunch is almost over. They spent the whole time alone.",
          choices: [
            %Choice{
              id: "nk-c4-last-chance",
              text: "Before the bell rings, quickly go say hi",
              next_scenario_id: "new-kid-last-minute",
              risk_level: :low,
              consequence_hint: "Better late than never"
            },
            %Choice{
              id: "nk-c4-tomorrow",
              text: "Think, 'I will talk to them tomorrow,' and leave when the bell rings",
              next_scenario_id: "new-kid-tomorrow-end",
              risk_level: :medium,
              consequence_hint: "Putting it off"
            }
          ],
          image_color: "#42A5F5"
        },
        "new-kid-wave" => %Scenario{
          id: "new-kid-wave",
          tree_id: "new-kid",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :friendship,
          level: 2,
          title: "A Friendly Wave",
          description:
            "You wave at the new kid and point to the empty seat next to you. The new kid looks surprised, then smiles a little. They pick up their tray and walk over slowly. 'Is it okay if I sit here?' they ask quietly. Your friends look up curiously.",
          choices: [
            %Choice{
              id: "nk-c5-welcome",
              text: "Scoot over and say, 'Of course! I am [your name]. What is yours?'",
              next_scenario_id: "new-kid-introduce",
              risk_level: :low,
              consequence_hint: "Warm welcome"
            },
            %Choice{
              id: "nk-c5-nod",
              text: "Nod and make room, but feel nervous about what to say next",
              next_scenario_id: "new-kid-nervous",
              risk_level: :low,
              consequence_hint: "You are nervous too"
            }
          ],
          image_color: "#66BB6A"
        },
        "new-kid-introduce" => %Scenario{
          id: "new-kid-introduce",
          tree_id: "new-kid",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :friendship,
          level: 3,
          title: "Introductions",
          description:
            "Jordan sits down at your table. You introduce everyone. 'This is Maya, and that is Chris, and over there is Sam.' Jordan smiles. 'Hi, everyone.' Maya asks, 'Where did you move from?' Jordan starts talking about their old school. Chris asks what video games they like. The conversation flows easily.",
          choices: [
            %Choice{
              id: "nk-c6-recess",
              text: "Ask Jordan if they want to hang out at recess too",
              next_scenario_id: "new-kid-recess-invite",
              risk_level: :low,
              consequence_hint: "Keep the connection going"
            },
            %Choice{
              id: "nk-c6-common",
              text: "Tell Jordan about something you both have in common",
              next_scenario_id: "new-kid-common-ground",
              risk_level: :low,
              consequence_hint: "Build a friendship"
            }
          ],
          image_color: "#66BB6A"
        },
        "new-kid-one-on-one" => %Scenario{
          id: "new-kid-one-on-one",
          tree_id: "new-kid",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :friendship,
          level: 3,
          title: "Just the Two of You",
          description:
            "You sit across from Jordan. 'I remember being new once. It was scary,' you say. Jordan looks relieved. 'It really is scary. I do not know anyone here. I do not even know where the library is.' You tell Jordan about the school and your favorite parts. Jordan starts to smile more.",
          choices: [
            %Choice{
              id: "nk-c7-show-around",
              text: "Offer to show Jordan around after lunch",
              next_scenario_id: "new-kid-tour",
              risk_level: :low,
              consequence_hint: "Be a guide"
            },
            %Choice{
              id: "nk-c7-meet-friends",
              text: "Ask if Jordan wants to meet your friends at recess",
              next_scenario_id: "new-kid-recess-invite",
              risk_level: :low,
              consequence_hint: "Expand the circle"
            }
          ],
          image_color: "#66BB6A"
        },
        "new-kid-stand-up" => %Scenario{
          id: "new-kid-stand-up",
          tree_id: "new-kid",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :friendship,
          level: 3,
          title: "Standing Up",
          description:
            "You say, 'They are not weird, they are just new. Everyone deserves a friend.' Your friend who said the mean thing gets quiet. Maya says, 'You are right. Let us invite them over.' Together, you wave the new kid over to your table. Your friend who was rude mumbles, 'Sorry. I did not think about it.' Jordan sits down and soon everyone is chatting.",
          choices: [
            %Choice{
              id: "nk-c8-include",
              text: "Make sure Jordan is included in the conversation",
              next_scenario_id: "new-kid-group-success",
              risk_level: :low,
              consequence_hint: "Include everyone"
            }
          ],
          image_color: "#66BB6A"
        },
        "new-kid-drop-it" => %Scenario{
          id: "new-kid-drop-it",
          tree_id: "new-kid",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :friendship,
          level: 3,
          title: "Giving In",
          description:
            "You go back to eating and do not say anything more. But the new kid stays alone for the whole lunch. On your way out, you see them walking alone in the hallway, looking lost. You feel bad that you let your friend's words stop you from doing the right thing.",
          choices: [
            %Choice{
              id: "nk-c9-hallway",
              text: "Catch up to the new kid in the hallway and say hello",
              next_scenario_id: "new-kid-hallway",
              risk_level: :low,
              consequence_hint: "Second chance"
            },
            %Choice{
              id: "nk-c9-regret",
              text: "Walk past them and feel guilty",
              next_scenario_id: "new-kid-regret-end",
              risk_level: :medium,
              consequence_hint: "Missed opportunity"
            }
          ],
          image_color: "#FFEE58"
        },
        "new-kid-last-minute" => %Scenario{
          id: "new-kid-last-minute",
          tree_id: "new-kid",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :friendship,
          level: 3,
          title: "Last-Minute Hello",
          description:
            "Just before the bell, you rush over. 'Hey! I am [your name]. I saw you sitting alone. I am sorry I did not come over sooner.' Jordan looks up and says, 'That is okay. I am Jordan.' The bell rings. 'Want to walk to class together?' you ask. Jordan nods, looking much happier.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You waited until the end of lunch, but you still made the choice to say hello. Is it better to be late being kind than to not be kind at all?",
          learning_points: [
            "It is never too late to do the right thing",
            "A small hello can change someone's whole day",
            "Next time, try to act sooner so the new person is not alone as long",
            "Being brave does not mean being first. It means doing it."
          ]
        },
        "new-kid-nervous" => %Scenario{
          id: "new-kid-nervous",
          tree_id: "new-kid",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :friendship,
          level: 3,
          title: "Both Nervous",
          description:
            "Jordan sits down and you both eat quietly for a moment. It is a little awkward. Then Jordan notices your lunchbox. 'Is that a dinosaur lunchbox? I love dinosaurs!' Suddenly you have something to talk about. You start sharing your favorite dinosaur facts, and Jordan lights up.",
          choices: [
            %Choice{
              id: "nk-c10-talk",
              text: "Keep talking about dinosaurs and share your favorite facts",
              next_scenario_id: "new-kid-common-ground",
              risk_level: :low,
              consequence_hint: "Found something in common"
            }
          ],
          image_color: "#66BB6A"
        },
        "new-kid-recess-invite" => %Scenario{
          id: "new-kid-recess-invite",
          tree_id: "new-kid",
          location: "Playground",
          location_category: :playground,
          theme: :friendship,
          level: 4,
          title: "Recess Together",
          description:
            "At recess, Jordan sticks close to you. You show them the best spot on the playground and introduce them to more kids. Jordan starts to relax and even laughs at a joke. At the end of recess, Jordan says, 'This is the first good day I have had since I moved. Thank you.'",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "Jordan said you made their first good day at a new school. How does it feel to know you made that big of a difference? What would you want someone to do for you if you were the new kid?",
          learning_points: [
            "Including someone new can change their whole experience",
            "Small acts of kindness can mean the world to someone",
            "Think about how you would feel if you were in their shoes",
            "Being a friend to someone new is one of the bravest things you can do"
          ]
        },
        "new-kid-common-ground" => %Scenario{
          id: "new-kid-common-ground",
          tree_id: "new-kid",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :friendship,
          level: 4,
          title: "Something in Common",
          description:
            "You and Jordan discover you both love the same things! You talk about your favorite books, games, and animals. Jordan says, 'I was so nervous today. I thought nobody would talk to me.' You say, 'I am glad I did.' By the time lunch ends, you have already made plans to sit together tomorrow.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "Finding something in common made it easy to connect with Jordan. What are some of your interests that might help you make friends with someone new?",
          learning_points: [
            "Shared interests are a great way to start friendships",
            "Asking questions helps you find things in common",
            "New friendships can start with one small conversation",
            "Everyone has something interesting about them if you ask"
          ]
        },
        "new-kid-tour" => %Scenario{
          id: "new-kid-tour",
          tree_id: "new-kid",
          location: "Hallway",
          location_category: :hallway,
          theme: :friendship,
          level: 4,
          title: "The Grand Tour",
          description:
            "After lunch, you show Jordan where the library is, where the gym is, and where the best water fountain is. Jordan laughs when you point out which bathroom is the cleanest. 'You are like a tour guide!' Jordan says. Your teacher sees you helping and gives you a big smile. 'That is very kind of you,' she says.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You used your knowledge of the school to help someone who was lost and confused. How does it feel to be the one who KNOWS things and can help? What other ways could you help a new student?",
          learning_points: [
            "Helping someone new shows leadership and kindness",
            "You have knowledge that can make someone else's life easier",
            "Being a guide helps the new person AND makes you feel good",
            "Adults notice and appreciate when you help others"
          ]
        },
        "new-kid-group-success" => %Scenario{
          id: "new-kid-group-success",
          tree_id: "new-kid",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :friendship,
          level: 4,
          title: "The Bigger Table",
          description:
            "Jordan fits right in with your group. By the end of lunch, even the friend who said the mean thing is laughing with Jordan. You stood up for what was right, and it made your whole group better. Jordan says, 'I was so scared to start a new school, but you all made it okay.' Your group has a new member, and everyone is better for it.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You stood up to a friend who said something unkind, and it led to the whole group becoming better. Is it hard to disagree with friends? Why was it worth it?",
          learning_points: [
            "Standing up for others, even to your friends, is important",
            "One brave voice can change a whole group's behavior",
            "People often regret unkind words when they see the impact",
            "Including new people makes your friend group richer and more fun"
          ]
        },
        "new-kid-hallway" => %Scenario{
          id: "new-kid-hallway",
          tree_id: "new-kid",
          location: "Hallway",
          location_category: :hallway,
          theme: :friendship,
          level: 4,
          title: "A Second Chance",
          description:
            "You catch up to Jordan in the hallway. 'Hey! I am [your name]. I saw you at lunch. Are you new?' Jordan nods. 'Yeah, I do not know where anything is.' You walk with Jordan to their next class and show them the way. 'Thanks,' Jordan says. 'Nobody talked to me all day until now.' You feel glad you finally spoke up, even if it was late.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :neutral,
          discussion_prompt:
            "You waited a long time but finally did the right thing. What held you back at lunch? What helped you finally go talk to Jordan?",
          learning_points: [
            "Sometimes we need time to work up courage, and that is okay",
            "Acting on kindness, even late, is better than not acting at all",
            "Peer pressure can make it hard to do what we know is right",
            "Next time, remember how good it felt and try to act sooner"
          ]
        },
        "new-kid-tomorrow-end" => %Scenario{
          id: "new-kid-tomorrow-end",
          tree_id: "new-kid",
          location: "Classroom",
          location_category: :classroom,
          theme: :friendship,
          level: 3,
          title: "Tomorrow Never Came",
          description:
            "The next day, the new kid is sitting alone again. And the day after that. Each day you think, 'I will do it tomorrow.' But by the end of the week, Jordan has started sitting in the corner of the library during lunch. They have stopped trying to find a table. You realize that 'tomorrow' might be too late.",
          choices: [],
          image_color: "#EC407A",
          is_game_over: true,
          outcome_type: :negative,
          discussion_prompt:
            "Putting something off can mean it never happens. Why is it hard to approach someone new? What would help you act right away instead of waiting?",
          learning_points: [
            "Putting off kind actions means the person keeps being alone",
            "Every day you wait, it gets harder for both of you",
            "The best time to be kind is right now, not tomorrow",
            "If it feels scary, remember: they are probably more scared than you"
          ]
        },
        "new-kid-regret-end" => %Scenario{
          id: "new-kid-regret-end",
          tree_id: "new-kid",
          location: "Hallway",
          location_category: :hallway,
          theme: :friendship,
          level: 4,
          title: "The One That Got Away",
          description:
            "You walk past Jordan in the hallway. They do not even look up anymore. Over the next few weeks, Jordan becomes very quiet and always sits alone. You think about them a lot and wish you had been braver. Your friend's unkind words stopped you from doing what you knew was right.",
          choices: [],
          image_color: "#EC407A",
          is_game_over: true,
          outcome_type: :negative,
          discussion_prompt:
            "Letting someone else's unkind words stop you from being kind is something many people experience. What could you do differently if this happened again? How can you be brave even when friends disagree?",
          learning_points: [
            "Peer pressure can stop us from doing what we know is right",
            "Your choice to be kind does not need anyone else's permission",
            "Regret about NOT doing something can last a long time",
            "Being brave means acting on your values, even when it is uncomfortable"
          ]
        }
      }
    }
  end
end
