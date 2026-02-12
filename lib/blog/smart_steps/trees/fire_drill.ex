defmodule Blog.SmartSteps.Trees.FireDrill do
  alias Blog.SmartSteps.Types.{ScenarioTree, Scenario, Choice}

  def tree do
    %ScenarioTree{
      id: "fire-drill",
      title: "The Fire Drill",
      description:
        "The fire alarm goes off during art class. You were in the middle of your favorite project. How do you handle this sudden change in routine?",
      theme: :routine_change,
      age_range: "6-12",
      estimated_minutes: 10,
      start_scenario_id: "fire-drill-start",
      scenarios: %{
        "fire-drill-start" => %Scenario{
          id: "fire-drill-start",
          tree_id: "fire-drill",
          location: "Art Classroom",
          location_category: :classroom,
          theme: :routine_change,
          level: 1,
          title: "The Alarm Goes Off",
          description:
            "You are painting your favorite picture in art class. Suddenly, the fire alarm starts blaring. It is very loud. Your teacher stands up and says, 'Everyone line up at the door!' You were right in the middle of painting the sky. Your hands are still covered in blue paint.",
          choices: [
            %Choice{
              id: "fd-c1-freeze",
              text: "Freeze and cover your ears because it is too loud",
              next_scenario_id: "fire-drill-freeze",
              risk_level: :high,
              consequence_hint: "The noise is overwhelming"
            },
            %Choice{
              id: "fd-c1-lineup",
              text: "Put down the brush and line up with the class",
              next_scenario_id: "fire-drill-lineup",
              risk_level: :low,
              consequence_hint: "Follow the routine"
            },
            %Choice{
              id: "fd-c1-headphones",
              text: "Ask the teacher if you can grab your headphones from your bag",
              next_scenario_id: "fire-drill-headphones",
              risk_level: :low,
              consequence_hint: "Use a coping tool"
            },
            %Choice{
              id: "fd-c1-run",
              text: "Run straight to the door without waiting for the class",
              next_scenario_id: "fire-drill-run",
              risk_level: :high,
              consequence_hint: "Panic reaction"
            }
          ],
          image_color: "#FFEE58"
        },
        "fire-drill-freeze" => %Scenario{
          id: "fire-drill-freeze",
          tree_id: "fire-drill",
          location: "Art Classroom",
          location_category: :classroom,
          theme: :routine_change,
          level: 2,
          title: "Frozen at Your Desk",
          description:
            "You cover your ears and close your eyes. The alarm is so loud it feels like it is inside your head. Your teacher notices you are still at your desk. She walks over and gently touches your shoulder. 'I know it is loud,' she says. 'Let me help you.'",
          choices: [
            %Choice{
              id: "fd-c2-accept-help",
              text: "Let the teacher help you get to the line",
              next_scenario_id: "fire-drill-teacher-help",
              risk_level: :low,
              consequence_hint: "Accept support"
            },
            %Choice{
              id: "fd-c2-cant-move",
              text: "You try but your body will not move. You start to cry.",
              next_scenario_id: "fire-drill-meltdown",
              risk_level: :critical,
              consequence_hint: "Overwhelm is building"
            },
            %Choice{
              id: "fd-c2-deep-breath",
              text: "Take three deep breaths and then stand up slowly",
              next_scenario_id: "fire-drill-breathe",
              risk_level: :low,
              consequence_hint: "Use a calming strategy"
            }
          ],
          image_color: "#9b59b6"
        },
        "fire-drill-lineup" => %Scenario{
          id: "fire-drill-lineup",
          tree_id: "fire-drill",
          location: "Art Classroom",
          location_category: :classroom,
          theme: :routine_change,
          level: 2,
          title: "In the Line",
          description:
            "You put down your brush and walk to the line. The alarm is still very loud and the hallway lights are flashing. Your classmate bumps into you while getting in line. Your hands are still covered in wet blue paint.",
          choices: [
            %Choice{
              id: "fd-c3-stay-line",
              text: "Stay in line and wipe paint on your smock. Keep walking.",
              next_scenario_id: "fire-drill-outside",
              risk_level: :low,
              consequence_hint: "Stay with the group"
            },
            %Choice{
              id: "fd-c3-upset-bump",
              text: "Get upset that someone bumped you and yell at them",
              next_scenario_id: "fire-drill-conflict",
              risk_level: :high,
              consequence_hint: "Emotions boiling over"
            },
            %Choice{
              id: "fd-c3-wash-hands",
              text: "Leave the line to go wash the paint off your hands",
              next_scenario_id: "fire-drill-leave-line",
              risk_level: :medium,
              consequence_hint: "Breaking from the group"
            }
          ],
          image_color: "#42A5F5"
        },
        "fire-drill-headphones" => %Scenario{
          id: "fire-drill-headphones",
          tree_id: "fire-drill",
          location: "Art Classroom",
          location_category: :classroom,
          theme: :routine_change,
          level: 2,
          title: "Headphones Ready",
          description:
            "Your teacher nods and says, 'Quick, grab them and get in line.' You grab your noise-canceling headphones from your bag and put them on. The sound becomes much quieter. You can still hear, but it does not hurt anymore. You get in line.",
          choices: [
            %Choice{
              id: "fd-c4-walk-out",
              text: "Walk with the class outside, feeling much calmer",
              next_scenario_id: "fire-drill-outside-calm",
              risk_level: :low,
              consequence_hint: "Coping tool worked"
            },
            %Choice{
              id: "fd-c4-help-friend",
              text: "Notice your friend looks scared. Tap their shoulder and give a thumbs-up.",
              next_scenario_id: "fire-drill-help-friend",
              risk_level: :low,
              consequence_hint: "Help someone else"
            }
          ],
          image_color: "#66BB6A"
        },
        "fire-drill-run" => %Scenario{
          id: "fire-drill-run",
          tree_id: "fire-drill",
          location: "Hallway",
          location_category: :hallway,
          theme: :routine_change,
          level: 2,
          title: "Running Ahead",
          description:
            "You bolt out the door and into the hallway. Other classes are filing out too. A teacher from another room stops you. 'Slow down! Where is your class?' she asks. You are breathing fast and your heart is pounding.",
          choices: [
            %Choice{
              id: "fd-c5-explain",
              text: "Tell the teacher you got scared by the loud alarm",
              next_scenario_id: "fire-drill-explain",
              risk_level: :low,
              consequence_hint: "Use your words"
            },
            %Choice{
              id: "fd-c5-keep-running",
              text: "Pull away and keep running toward the exit",
              next_scenario_id: "fire-drill-unsafe-end",
              risk_level: :critical,
              consequence_hint: "Unsafe behavior"
            }
          ],
          image_color: "#EC407A"
        },
        "fire-drill-teacher-help" => %Scenario{
          id: "fire-drill-teacher-help",
          tree_id: "fire-drill",
          location: "Hallway",
          location_category: :hallway,
          theme: :routine_change,
          level: 3,
          title: "Walking with the Teacher",
          description:
            "Your teacher walks beside you and lets you hold onto her sleeve. She puts her hand gently on your back. 'You are doing great,' she says. 'We will be outside in just a minute.' The alarm is still loud, but having the teacher next to you helps.",
          choices: [
            %Choice{
              id: "fd-c6-outside",
              text: "Keep walking with the teacher until you are outside",
              next_scenario_id: "fire-drill-outside",
              risk_level: :low,
              consequence_hint: "Almost there"
            }
          ],
          image_color: "#42A5F5"
        },
        "fire-drill-meltdown" => %Scenario{
          id: "fire-drill-meltdown",
          tree_id: "fire-drill",
          location: "Art Classroom",
          location_category: :classroom,
          theme: :routine_change,
          level: 3,
          title: "Too Much at Once",
          description:
            "The noise, the flashing lights, and the change in routine are all too much. You start crying and cannot get up. Your teacher stays with you and helps block the light. She talks in a calm, quiet voice. Another adult comes to help the rest of the class. You missed the fire drill, but your teacher helped you stay safe until it was over.",
          choices: [],
          image_color: "#9b59b6",
          is_game_over: true,
          outcome_type: :negative,
          discussion_prompt:
            "Sometimes everything feels like too much at the same time. That is okay. What could you do BEFORE a fire drill to feel more prepared? What tools or plans could help?",
          learning_points: [
            "Having a plan ahead of time can make surprises less scary",
            "It is okay to ask for help before you reach the breaking point",
            "Sensory tools like headphones can help in loud situations",
            "Adults can help you practice what to do so it feels less new"
          ]
        },
        "fire-drill-breathe" => %Scenario{
          id: "fire-drill-breathe",
          tree_id: "fire-drill",
          location: "Art Classroom",
          location_category: :classroom,
          theme: :routine_change,
          level: 3,
          title: "Breathing Helps",
          description:
            "You take three slow, deep breaths. In through your nose, out through your mouth. Your body starts to feel a little calmer. You stand up, and your teacher smiles. 'Great job using your breathing,' she says. You join the end of the line.",
          choices: [
            %Choice{
              id: "fd-c7-outside",
              text: "Walk outside with the class",
              next_scenario_id: "fire-drill-outside",
              risk_level: :low,
              consequence_hint: "Calming strategy worked"
            }
          ],
          image_color: "#66BB6A"
        },
        "fire-drill-outside" => %Scenario{
          id: "fire-drill-outside",
          tree_id: "fire-drill",
          location: "School Yard",
          location_category: :playground,
          theme: :routine_change,
          level: 4,
          title: "Outside and Safe",
          description:
            "You are outside now. The alarm is much quieter out here. Your class stands in a line on the grass. The teacher does a head count. You made it! But you still feel shaky. A friend says, 'That was so loud, right?'",
          choices: [
            %Choice{
              id: "fd-c8-agree",
              text: "Nod and say, 'Yeah, I do not like how loud it is.'",
              next_scenario_id: "fire-drill-shared-feeling",
              risk_level: :low,
              consequence_hint: "Share your feelings"
            },
            %Choice{
              id: "fd-c8-quiet",
              text: "Stay quiet. You do not feel like talking yet.",
              next_scenario_id: "fire-drill-quiet-end",
              risk_level: :medium,
              consequence_hint: "Need more time"
            }
          ],
          image_color: "#66BB6A"
        },
        "fire-drill-conflict" => %Scenario{
          id: "fire-drill-conflict",
          tree_id: "fire-drill",
          location: "Hallway",
          location_category: :hallway,
          theme: :routine_change,
          level: 3,
          title: "Words You Regret",
          description:
            "You yell, 'Watch where you are going!' at your classmate. They look hurt and scared. The teacher comes over and says, 'I know this is stressful, but we need to stay calm and keep moving.' Other kids are looking at you.",
          choices: [
            %Choice{
              id: "fd-c9-apologize",
              text: "Take a breath and say sorry to your classmate",
              next_scenario_id: "fire-drill-apologize",
              risk_level: :low,
              consequence_hint: "Make it right"
            },
            %Choice{
              id: "fd-c9-refuse",
              text: "Cross your arms and refuse to move",
              next_scenario_id: "fire-drill-refuse-end",
              risk_level: :high,
              consequence_hint: "Digging in"
            }
          ],
          image_color: "#EC407A"
        },
        "fire-drill-leave-line" => %Scenario{
          id: "fire-drill-leave-line",
          tree_id: "fire-drill",
          location: "Hallway Bathroom",
          location_category: :hallway,
          theme: :routine_change,
          level: 3,
          title: "Alone in the Hallway",
          description:
            "You step out of line and head toward the bathroom. The hallway is empty now. The alarm is still going. Your teacher calls your name but you are already around the corner. You are alone, and the hallway feels strange and echoey.",
          choices: [
            %Choice{
              id: "fd-c10-go-back",
              text: "Go back to your class line right away",
              next_scenario_id: "fire-drill-outside",
              risk_level: :low,
              consequence_hint: "Correct course"
            },
            %Choice{
              id: "fd-c10-stay",
              text: "Go into the bathroom to wash your hands anyway",
              next_scenario_id: "fire-drill-lost-end",
              risk_level: :high,
              consequence_hint: "Separated from class"
            }
          ],
          image_color: "#FFEE58"
        },
        "fire-drill-outside-calm" => %Scenario{
          id: "fire-drill-outside-calm",
          tree_id: "fire-drill",
          location: "School Yard",
          location_category: :playground,
          theme: :routine_change,
          level: 3,
          title: "Calm and Prepared",
          description:
            "You walk outside with your headphones on, feeling calm. Your teacher gives you a smile and a thumbs-up. 'Great job being prepared,' she says. The fire drill ends and everyone goes back inside. You used your coping tool and handled a surprise really well!",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You used headphones to help with the loud sound. What other tools or strategies do you have for when things get too loud or too surprising?",
          learning_points: [
            "Having sensory tools ready helps you handle surprises",
            "Asking for what you need is a strong skill, not a weakness",
            "Planning ahead for things that bother you is smart self-advocacy",
            "You can follow safety rules AND take care of your own needs"
          ]
        },
        "fire-drill-help-friend" => %Scenario{
          id: "fire-drill-help-friend",
          tree_id: "fire-drill",
          location: "School Yard",
          location_category: :playground,
          theme: :routine_change,
          level: 3,
          title: "Helping a Friend",
          description:
            "Your friend sees your thumbs-up and smiles a little. 'Thanks,' they whisper. You walk outside together. After the drill, your friend says, 'I was really scared. You helped me feel better.' You feel proud that even though the alarm was hard for you, you could help someone else too.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You managed your own feelings AND helped a friend. How did it feel to help someone when you were also having a hard time? Can helping others sometimes help us feel better too?",
          learning_points: [
            "When you manage your own needs, you can also help others",
            "Small gestures like a thumbs-up can make someone feel safe",
            "Being a good friend does not mean you have no struggles",
            "Using your tools frees you up to notice what others need"
          ]
        },
        "fire-drill-explain" => %Scenario{
          id: "fire-drill-explain",
          tree_id: "fire-drill",
          location: "Hallway",
          location_category: :hallway,
          theme: :routine_change,
          level: 3,
          title: "Using Your Words",
          description:
            "You tell the teacher, 'The alarm scared me. It was really loud and I just ran.' The teacher nods. 'I understand. Let me walk you to your class line outside.' She helps you find your class, and your art teacher is relieved to see you. 'Next time, try to stay with us. But I am glad you are okay.'",
          choices: [],
          image_color: "#42A5F5",
          is_game_over: true,
          outcome_type: :neutral,
          discussion_prompt:
            "You ran ahead because you were scared, but then you used your words to explain. What could you do differently next time so you do not get separated from your class?",
          learning_points: [
            "Explaining your feelings helps adults understand and help you",
            "Running away from the group can be unsafe even if it feels right",
            "It is okay to be scared, but staying with your class is the safest choice",
            "Making a plan for loud sounds can help you feel less panicked"
          ]
        },
        "fire-drill-unsafe-end" => %Scenario{
          id: "fire-drill-unsafe-end",
          tree_id: "fire-drill",
          location: "School Entrance",
          location_category: :hallway,
          theme: :routine_change,
          level: 3,
          title: "Separated and Unsafe",
          description:
            "You pull away and run. You end up outside but far from your class. No teacher can see you. You are safe from the drill, but you are alone and no one knows where you are. An adult eventually finds you and brings you to the office. Your parents are called.",
          choices: [],
          image_color: "#EC407A",
          is_game_over: true,
          outcome_type: :severe,
          discussion_prompt:
            "Running away felt like the only option, but it put you in an unsafe situation. What could adults do to help you feel safer during fire drills? What could you ask for before a drill happens?",
          learning_points: [
            "Staying with your group during emergencies keeps you safe",
            "Adults need to know where you are to help you",
            "If you feel like running, try to tell an adult first",
            "A safety plan made before the drill can prevent panic"
          ]
        },
        "fire-drill-shared-feeling" => %Scenario{
          id: "fire-drill-shared-feeling",
          tree_id: "fire-drill",
          location: "School Yard",
          location_category: :playground,
          theme: :routine_change,
          level: 5,
          title: "You Are Not Alone",
          description:
            "Your friend nods. 'Me too! It always scares me,' they say. Other kids nearby agree. You realize that the fire drill was hard for a lot of people, not just you. The drill ends, and everyone goes back inside. You feel tired but proud that you made it through.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You shared how you felt and learned that other kids feel the same way. Why does it help to know that other people feel the same things you do?",
          learning_points: [
            "Sharing your feelings can help you and others feel less alone",
            "Many people find fire drills hard, not just you",
            "Being honest about what is difficult is brave",
            "Getting through something hard is something to be proud of"
          ]
        },
        "fire-drill-quiet-end" => %Scenario{
          id: "fire-drill-quiet-end",
          tree_id: "fire-drill",
          location: "School Yard",
          location_category: :playground,
          theme: :routine_change,
          level: 5,
          title: "Quiet Recovery",
          description:
            "You stay quiet and wait. Your friend does not push you to talk, which is nice. After a few minutes, the drill ends and everyone goes back inside. You feel drained but you did it. You followed the fire drill steps even though it was really hard.",
          choices: [],
          image_color: "#42A5F5",
          is_game_over: true,
          outcome_type: :neutral,
          discussion_prompt:
            "Sometimes we need quiet time after something stressful. That is completely okay. Is there something you could do after a hard moment to help yourself feel better?",
          learning_points: [
            "Needing quiet time after stress is a valid way to recover",
            "You do not have to talk about your feelings right away",
            "Getting through the drill is a success, even if it was hard",
            "Knowing what helps you recover is important self-awareness"
          ]
        },
        "fire-drill-apologize" => %Scenario{
          id: "fire-drill-apologize",
          tree_id: "fire-drill",
          location: "School Yard",
          location_category: :playground,
          theme: :routine_change,
          level: 4,
          title: "Making It Right",
          description:
            "You take a breath and say, 'Sorry I yelled. The alarm made me really stressed.' Your classmate says, 'It is okay. It scared me too.' You walk outside together. The teacher tells you she is proud of you for apologizing, even when you were upset.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You were stressed and said something you did not mean, but you apologized. What does it feel like to apologize? Does it make things better?",
          learning_points: [
            "Stress can make us snap at people, but we can make it right",
            "A quick apology can fix a situation before it gets worse",
            "Explaining WHY you reacted helps others understand",
            "Apologizing shows strength, not weakness"
          ]
        },
        "fire-drill-refuse-end" => %Scenario{
          id: "fire-drill-refuse-end",
          tree_id: "fire-drill",
          location: "Hallway",
          location_category: :hallway,
          theme: :routine_change,
          level: 4,
          title: "Stuck in the Storm",
          description:
            "You cross your arms and will not move. The alarm is still blaring. Your teacher has to stay with you while another adult takes the class outside. You end up being the last one inside. By the time you get outside, the drill is almost over. You feel exhausted and embarrassed.",
          choices: [],
          image_color: "#EC407A",
          is_game_over: true,
          outcome_type: :negative,
          discussion_prompt:
            "When we get upset, sometimes our body wants to shut down. What could you do instead of refusing to move? What would help you feel safe enough to keep going?",
          learning_points: [
            "Shutting down makes stressful situations last longer",
            "Asking for help is better than refusing to move",
            "Having a buddy or a plan can make hard moments easier",
            "It is okay to be upset, but staying safe comes first"
          ]
        },
        "fire-drill-lost-end" => %Scenario{
          id: "fire-drill-lost-end",
          tree_id: "fire-drill",
          location: "School Bathroom",
          location_category: :hallway,
          theme: :routine_change,
          level: 4,
          title: "Left Behind",
          description:
            "You go into the bathroom and wash your hands. By the time you come out, the hallway is completely empty. Everyone is outside. You are alone inside the school during a fire drill. A staff member eventually finds you and takes you outside. Your teacher was very worried.",
          choices: [],
          image_color: "#EC407A",
          is_game_over: true,
          outcome_type: :negative,
          discussion_prompt:
            "The paint on your hands felt uncomfortable, and you wanted to fix it. But leaving the line meant you were alone and unsafe. How could you handle the uncomfortable feeling AND stay safe?",
          learning_points: [
            "Safety rules are more important than comfort in emergencies",
            "You can clean up after the drill is over",
            "Staying with the group keeps everyone safe",
            "If something bothers you, tell an adult instead of leaving on your own"
          ]
        }
      }
    }
  end
end
