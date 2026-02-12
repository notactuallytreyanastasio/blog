defmodule Blog.SmartSteps.Trees.Playground do
  alias Blog.SmartSteps.Types.{ScenarioTree, Scenario, Choice}

  def tree do
    %ScenarioTree{
      id: "playground",
      title: "The Playground",
      description:
        "You are at recess when you see an older kid being mean to a younger kid on the playground. The younger kid looks scared and upset. What do you do?",
      theme: :bullying,
      age_range: "6-12",
      estimated_minutes: 10,
      start_scenario_id: "play-start",
      scenarios: %{
        "play-start" => %Scenario{
          id: "play-start",
          tree_id: "playground",
          location: "Playground",
          location_category: :playground,
          theme: :bullying,
          level: 1,
          title: "Something Is Not Right",
          description:
            "You are playing near the swings when you notice something happening by the slide. An older kid, Marcus, is standing over a younger kid named Sam. Marcus is knocking Sam's hat off his head and saying, 'What are you going to do about it?' Sam picks up his hat and Marcus knocks it off again. Sam looks like he is about to cry. Other kids are walking past and pretending not to see.",
          choices: [
            %Choice{
              id: "play-c1-get-adult",
              text: "Go find a teacher or recess monitor right away",
              next_scenario_id: "play-get-adult",
              risk_level: :low,
              consequence_hint: "Get help from an adult"
            },
            %Choice{
              id: "play-c1-speak-up",
              text: "Walk over and say, 'Hey, leave him alone!'",
              next_scenario_id: "play-speak-up",
              risk_level: :medium,
              consequence_hint: "Stand up directly"
            },
            %Choice{
              id: "play-c1-distract",
              text: "Walk over to Sam and say, 'Hey Sam, come play with us!'",
              next_scenario_id: "play-distract",
              risk_level: :low,
              consequence_hint: "Create an exit for Sam"
            },
            %Choice{
              id: "play-c1-ignore",
              text: "Look away and keep playing. It is not your problem.",
              next_scenario_id: "play-ignore",
              risk_level: :high,
              consequence_hint: "Pretend you did not see"
            }
          ],
          image_color: "#FFEE58"
        },
        "play-get-adult" => %Scenario{
          id: "play-get-adult",
          tree_id: "playground",
          location: "Playground",
          location_category: :playground,
          theme: :bullying,
          level: 2,
          title: "Finding Help",
          description:
            "You run across the playground to where Ms. Hernandez is standing. 'Ms. Hernandez! Someone is being mean to Sam by the slide!' She looks serious and says, 'Show me where.' She walks quickly toward the slide with you. Marcus sees the teacher coming and steps away from Sam.",
          choices: [
            %Choice{
              id: "play-c2-stay-with-teacher",
              text: "Stay with Ms. Hernandez while she talks to Marcus",
              next_scenario_id: "play-witness",
              risk_level: :low,
              consequence_hint: "Be a witness"
            },
            %Choice{
              id: "play-c2-check-sam",
              text: "Go over to Sam and make sure he is okay",
              next_scenario_id: "play-comfort-sam",
              risk_level: :low,
              consequence_hint: "Support the kid who was hurt"
            }
          ],
          image_color: "#42A5F5"
        },
        "play-speak-up" => %Scenario{
          id: "play-speak-up",
          tree_id: "playground",
          location: "Playground - By the Slide",
          location_category: :playground,
          theme: :bullying,
          level: 2,
          title: "Standing Up",
          description:
            "You walk over and say, 'Hey, leave him alone!' Marcus turns to look at you. He is bigger than you. 'Mind your own business,' he says. Sam looks at you with wide eyes. He looks a little hopeful that someone noticed. Other kids on the playground are watching now.",
          choices: [
            %Choice{
              id: "play-c3-stay-firm",
              text: "Say, 'What you are doing is not okay. I am getting a teacher.'",
              next_scenario_id: "play-firm-then-adult",
              risk_level: :low,
              consequence_hint: "Stand firm and get help"
            },
            %Choice{
              id: "play-c3-argue",
              text: "Get in Marcus's face and say, 'Leave him alone or else!'",
              next_scenario_id: "play-escalate",
              risk_level: :critical,
              consequence_hint: "This could get physical"
            },
            %Choice{
              id: "play-c3-freeze",
              text: "You said something, but now you are scared. You freeze up.",
              next_scenario_id: "play-freeze",
              risk_level: :medium,
              consequence_hint: "Courage is hard to maintain"
            }
          ],
          image_color: "#EC407A"
        },
        "play-distract" => %Scenario{
          id: "play-distract",
          tree_id: "playground",
          location: "Playground - By the Slide",
          location_category: :playground,
          theme: :bullying,
          level: 2,
          title: "An Exit Strategy",
          description:
            "You walk over casually and say, 'Hey Sam, come play with us! We need one more person for our game.' Sam looks at you with relief. Marcus looks annoyed but is not sure what to say since you are not confronting him directly. Sam grabs his hat and starts walking toward you.",
          choices: [
            %Choice{
              id: "play-c4-walk-away-sam",
              text: "Walk away with Sam toward your friends",
              next_scenario_id: "play-safe-with-friends",
              risk_level: :low,
              consequence_hint: "Remove Sam from the situation"
            },
            %Choice{
              id: "play-c4-marcus-follows",
              text: "Marcus follows you and says, 'Where do you think you are going?'",
              next_scenario_id: "play-marcus-follows",
              risk_level: :medium,
              consequence_hint: "It is not over yet"
            }
          ],
          image_color: "#66BB6A"
        },
        "play-ignore" => %Scenario{
          id: "play-ignore",
          tree_id: "playground",
          location: "Playground",
          location_category: :playground,
          theme: :bullying,
          level: 2,
          title: "Looking Away",
          description:
            "You turn away and keep playing. But you can still hear Marcus laughing and Sam's quiet voice saying, 'Please stop.' Your stomach feels tight. You try to have fun but you keep glancing back. Sam is sitting on the ground now, looking down. No one is helping him.",
          choices: [
            %Choice{
              id: "play-c5-change-mind",
              text: "You cannot ignore it anymore. Go get a teacher.",
              next_scenario_id: "play-change-mind",
              risk_level: :low,
              consequence_hint: "It is not too late to help"
            },
            %Choice{
              id: "play-c5-keep-ignoring",
              text: "Keep playing. Someone else will probably help.",
              next_scenario_id: "play-bystander-end",
              risk_level: :high,
              consequence_hint: "No one steps up"
            }
          ],
          image_color: "#FFEE58"
        },
        "play-witness" => %Scenario{
          id: "play-witness",
          tree_id: "playground",
          location: "Playground - By the Slide",
          location_category: :playground,
          theme: :bullying,
          level: 3,
          title: "Telling What You Saw",
          description:
            "Ms. Hernandez asks Marcus what happened. Marcus says, 'We were just playing.' Ms. Hernandez turns to you. 'Can you tell me what you saw?' You take a breath and describe exactly what happened. Marcus looks angry, but Ms. Hernandez thanks you. 'It takes courage to speak up,' she says. She takes Marcus to talk privately and another teacher checks on Sam.",
          choices: [],
          image_color: "#42A5F5",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You told the teacher exactly what happened, even though it was hard. Marcus might be upset with you. Was telling the truth the right thing to do? What could you do if Marcus tries to bother you later?",
          learning_points: [
            "Telling a trusted adult what you saw is not tattling. It is reporting.",
            "Tattling is trying to get someone in trouble. Reporting is trying to keep someone safe.",
            "Being a witness takes courage, and adults need your help to stop bullying",
            "If you are worried about the bully being upset with you, tell an adult that too"
          ]
        },
        "play-comfort-sam" => %Scenario{
          id: "play-comfort-sam",
          tree_id: "playground",
          location: "Playground - By the Slide",
          location_category: :playground,
          theme: :bullying,
          level: 3,
          title: "Being There for Sam",
          description:
            "You walk over to Sam while Ms. Hernandez deals with Marcus. Sam is sitting on the ground holding his hat. His eyes are red. You sit down next to him. 'Are you okay?' you ask. Sam shrugs. 'He does that every day,' Sam says quietly. 'Every day?' you ask. 'You should tell a teacher.' Sam says, 'I am scared to.'",
          choices: [
            %Choice{
              id: "play-c6-offer-together",
              text: "Say, 'I will go with you. We can tell together.'",
              next_scenario_id: "play-tell-together-end",
              risk_level: :low,
              consequence_hint: "Support makes it easier"
            },
            %Choice{
              id: "play-c6-tell-for-sam",
              text: "Say, 'I already told Ms. Hernandez. She is helping.'",
              next_scenario_id: "play-already-helped-end",
              risk_level: :low,
              consequence_hint: "Reassure Sam"
            }
          ],
          image_color: "#42A5F5"
        },
        "play-firm-then-adult" => %Scenario{
          id: "play-firm-then-adult",
          tree_id: "playground",
          location: "Playground",
          location_category: :playground,
          theme: :bullying,
          level: 3,
          title: "Firm and Smart",
          description:
            "You say clearly, 'What you are doing is not okay. I am getting a teacher.' Marcus says, 'Whatever, snitch.' But he steps away from Sam. You walk quickly to the nearest recess monitor and explain what happened. The monitor goes to talk to Marcus. Sam catches up to you and says, 'Thank you. No one ever helps me.'",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "Marcus called you a 'snitch' for getting help. How does that word make you feel? Is there a difference between snitching and helping someone who is being hurt?",
          learning_points: [
            "Standing up for someone does not make you a snitch. It makes you brave.",
            "The word 'snitch' is often used by bullies to stop people from getting help",
            "Speaking up AND getting an adult is the safest and most effective strategy",
            "You can be firm without being aggressive"
          ]
        },
        "play-escalate" => %Scenario{
          id: "play-escalate",
          tree_id: "playground",
          location: "Playground - By the Slide",
          location_category: :playground,
          theme: :bullying,
          level: 3,
          title: "The Situation Explodes",
          description:
            "You get in Marcus's face and say, 'Leave him alone or else!' Marcus shoves you. You shove back. A crowd forms. A teacher runs over and both you and Marcus are pulled apart. Now you are BOTH in trouble. Sam is still upset, and now you are being sent to the office too. The principal calls your parents. You were trying to help, but it turned into a fight.",
          choices: [],
          image_color: "#EC407A",
          is_game_over: true,
          outcome_type: :severe,
          discussion_prompt:
            "You wanted to help Sam, and that instinct was good. But getting physical made things worse for everyone. What could you have done to help Sam without getting into a fight?",
          learning_points: [
            "Wanting to help is good, but how you help matters just as much",
            "Getting physical turns you from a helper into someone who is also in trouble",
            "You can be strong and brave without using your hands",
            "Getting an adult is almost always more effective than confronting a bully alone"
          ]
        },
        "play-freeze" => %Scenario{
          id: "play-freeze",
          tree_id: "playground",
          location: "Playground - By the Slide",
          location_category: :playground,
          theme: :bullying,
          level: 3,
          title: "Frozen in the Moment",
          description:
            "You said something brave, but now Marcus is staring at you and your body freezes. You cannot think of what to say next. Marcus laughs. 'That is what I thought,' he says and turns back to Sam. You feel terrible. You tried, but the words stopped coming. Then you hear another voice. A classmate named Jordan walks over and says, 'Come on, let us go tell a teacher.' Jordan takes your arm and you both go find help.",
          choices: [],
          image_color: "#42A5F5",
          is_game_over: true,
          outcome_type: :neutral,
          discussion_prompt:
            "You froze after speaking up, and that felt awful. But then Jordan stepped in to help. Why is it important that you do not have to handle everything by yourself? What did you do right, even if it did not feel like enough?",
          learning_points: [
            "Freezing up is a normal response to a scary situation, not a failure",
            "You spoke up first, and that took real courage even if you froze after",
            "Having someone join you makes it easier to take the next step",
            "You do not have to be the only hero. Getting others involved is smart."
          ]
        },
        "play-safe-with-friends" => %Scenario{
          id: "play-safe-with-friends",
          tree_id: "playground",
          location: "Playground",
          location_category: :playground,
          theme: :bullying,
          level: 3,
          title: "Safety in Numbers",
          description:
            "You and Sam walk to your group of friends. 'Want to play tag?' someone asks. Sam nods and joins in. Being around other kids makes Marcus much less likely to bother him. Sam laughs for the first time all recess. After the game, you quietly tell Sam, 'If Marcus bothers you again, come find us.'",
          choices: [
            %Choice{
              id: "play-c7-tell-adult-later",
              text: "Also tell a teacher about what Marcus was doing, just in case",
              next_scenario_id: "play-report-later-end",
              risk_level: :low,
              consequence_hint: "Make sure an adult knows"
            },
            %Choice{
              id: "play-c7-leave-it",
              text: "You helped Sam. That is enough. No need to involve a teacher.",
              next_scenario_id: "play-partial-help-end",
              risk_level: :medium,
              consequence_hint: "The problem might continue"
            }
          ],
          image_color: "#66BB6A"
        },
        "play-marcus-follows" => %Scenario{
          id: "play-marcus-follows",
          tree_id: "playground",
          location: "Playground",
          location_category: :playground,
          theme: :bullying,
          level: 3,
          title: "Marcus Is Not Done",
          description:
            "Marcus follows you and Sam. 'Where do you think you are going?' he says. Sam tenses up beside you. Marcus is trying to show he is still in control. Other kids nearby are watching to see what happens next.",
          choices: [
            %Choice{
              id: "play-c8-loud-voice",
              text: "Use a loud, clear voice: 'We are going to play. Please leave us alone.'",
              next_scenario_id: "play-assertive-end",
              risk_level: :low,
              consequence_hint: "Draw attention to the situation"
            },
            %Choice{
              id: "play-c8-run-to-teacher",
              text: "Say to Sam, 'Come on, let us go to the teacher.'",
              next_scenario_id: "play-smart-exit-end",
              risk_level: :low,
              consequence_hint: "Get help now"
            }
          ],
          image_color: "#EC407A"
        },
        "play-change-mind" => %Scenario{
          id: "play-change-mind",
          tree_id: "playground",
          location: "Playground",
          location_category: :playground,
          theme: :bullying,
          level: 3,
          title: "Changing Course",
          description:
            "You cannot shake the tight feeling in your stomach. You stop playing and run to find a teacher. You tell her what you saw. She goes to help Sam right away. On the way back from getting help, you think about how long you waited. Sam was alone that whole time. But at least you did something before recess ended.",
          choices: [],
          image_color: "#42A5F5",
          is_game_over: true,
          outcome_type: :neutral,
          discussion_prompt:
            "You ignored the situation at first but then changed your mind and got help. What made you change your mind? Is it better to act late than not at all?",
          learning_points: [
            "It is never too late to do the right thing",
            "That uncomfortable feeling in your stomach was telling you something important",
            "Acting sooner is better, but acting late is still better than not acting at all",
            "Next time, you can listen to that gut feeling right away"
          ]
        },
        "play-bystander-end" => %Scenario{
          id: "play-bystander-end",
          tree_id: "playground",
          location: "Playground",
          location_category: :playground,
          theme: :bullying,
          level: 3,
          title: "The Bystander",
          description:
            "You keep playing, telling yourself someone else will help. But no one does. The bell rings and everyone goes inside. You see Sam walking alone, head down, hat crumpled in his hand. He looks defeated. That night, you cannot stop thinking about it. You saw something wrong and did nothing. The feeling stays with you.",
          choices: [],
          image_color: "#9b59b6",
          is_game_over: true,
          outcome_type: :negative,
          discussion_prompt:
            "You hoped someone else would help, but no one did. This is called the 'bystander effect.' How did it feel to see Sam walking alone after recess? What would you do differently tomorrow?",
          learning_points: [
            "When everyone thinks someone else will help, no one helps",
            "Being a bystander means seeing something wrong and not acting",
            "It is normal to feel scared about getting involved, but inaction has consequences too",
            "Even small actions, like telling one adult, can change everything for someone"
          ]
        },
        "play-tell-together-end" => %Scenario{
          id: "play-tell-together-end",
          tree_id: "playground",
          location: "Playground",
          location_category: :playground,
          theme: :bullying,
          level: 4,
          title: "Standing Together",
          description:
            "You say, 'I will go with you. We can tell together.' Sam looks at you and slowly nods. You walk together to Ms. Hernandez. Sam is nervous but with you standing beside him, he tells her everything. He tells her it has been happening every day for weeks. Ms. Hernandez listens carefully and promises to make sure it stops. Sam looks at you and says, 'Thank you for staying with me.'",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "Sam was too scared to report on his own, but having you beside him gave him the courage. Why is it easier to do hard things with someone by your side? How can you be that person for others?",
          learning_points: [
            "Being there for someone can give them the courage to speak up",
            "Reporting bullying together makes it less scary for the person being bullied",
            "Learning that the bullying happened every day shows why reporting matters",
            "Supporting someone through a hard conversation is one of the kindest things you can do"
          ]
        },
        "play-already-helped-end" => %Scenario{
          id: "play-already-helped-end",
          tree_id: "playground",
          location: "Playground",
          location_category: :playground,
          theme: :bullying,
          level: 4,
          title: "Help Is Already Here",
          description:
            "You tell Sam, 'I already told Ms. Hernandez. She is helping right now.' Sam's shoulders drop with relief. 'Really?' he says. 'Really,' you say. 'You do not have to deal with this alone.' You sit with Sam until he feels better. When the bell rings, Sam walks inside with you and your friends instead of alone. It is a small thing, but it matters a lot.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You got help AND comforted Sam. How did sitting with him make a difference? Why does it matter that Sam walked inside with friends instead of alone?",
          learning_points: [
            "Getting help is step one. Staying to comfort the person is step two.",
            "Sometimes just sitting with someone who is upset is exactly what they need",
            "Walking with someone sends a message: 'You are not alone'",
            "Being a good helper means caring about the person, not just solving the problem"
          ]
        },
        "play-report-later-end" => %Scenario{
          id: "play-report-later-end",
          tree_id: "playground",
          location: "Classroom",
          location_category: :classroom,
          theme: :bullying,
          level: 4,
          title: "The Full Picture",
          description:
            "After recess, you go to your teacher and quietly tell them what you saw Marcus doing to Sam. Your teacher thanks you and says, 'I will make sure the counselor knows, and we will keep an eye on this.' You helped Sam in the moment AND made sure adults know about the pattern. Sam has a better chance of being safe from now on because you reported it.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You helped Sam twice: once in the moment and once by reporting to a teacher. Why is it important to tell an adult even after you have already helped? What can adults do that kids cannot?",
          learning_points: [
            "Helping in the moment is great, but adults need to know about ongoing bullying",
            "Adults can create long-term solutions that kids cannot",
            "Reporting is not just about one incident. It is about stopping a pattern.",
            "You can be a helper AND a reporter. Both are important."
          ]
        },
        "play-partial-help-end" => %Scenario{
          id: "play-partial-help-end",
          tree_id: "playground",
          location: "Playground",
          location_category: :playground,
          theme: :bullying,
          level: 4,
          title: "A Temporary Fix",
          description:
            "You helped Sam today, and that is something to feel good about. But the next day, you see Marcus bothering Sam again. Without an adult knowing, the bullying continues. Sam looks at you from across the playground with a look that says, 'Please help again.' You realize that helping in the moment was not enough. Marcus needs an adult to set a boundary.",
          choices: [],
          image_color: "#FFEE58",
          is_game_over: true,
          outcome_type: :neutral,
          discussion_prompt:
            "You helped Sam once, but the bullying came back the next day. Why was your help only temporary? What is the difference between solving a moment and solving a problem?",
          learning_points: [
            "Helping someone in the moment is great, but bullying usually needs adult involvement to stop",
            "Bullies often repeat their behavior unless an adult intervenes",
            "Reporting is not optional when someone is being hurt regularly",
            "You made a good start. The next step is telling an adult."
          ]
        },
        "play-assertive-end" => %Scenario{
          id: "play-assertive-end",
          tree_id: "playground",
          location: "Playground",
          location_category: :playground,
          theme: :bullying,
          level: 4,
          title: "A Clear Message",
          description:
            "You use a loud, clear voice so other kids can hear: 'We are going to play. Please leave us alone.' Several kids nearby look over. Marcus realizes people are watching and he does not want a teacher to notice. He rolls his eyes and says, 'Whatever,' and walks away. Sam takes a big breath. 'That was so cool,' he says. You feel your heart pounding, but you also feel proud.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "Using a loud, clear voice drew attention to the situation and made Marcus back off. Why does drawing attention to bullying often stop it? Should you also tell a teacher what happened?",
          learning_points: [
            "Bullies often rely on no one paying attention. Drawing attention disrupts that.",
            "A firm, clear voice is a powerful tool. You do not need to yell or threaten.",
            "Even after the bully walks away, it is smart to tell an adult so they can watch for it",
            "Being assertive is different from being aggressive. Assertive keeps everyone safe."
          ]
        },
        "play-smart-exit-end" => %Scenario{
          id: "play-smart-exit-end",
          tree_id: "playground",
          location: "Playground",
          location_category: :playground,
          theme: :bullying,
          level: 4,
          title: "The Smart Exit",
          description:
            "You say to Sam, 'Come on, let us go to the teacher.' You both walk quickly toward the recess monitor. Marcus does not follow because he knows he will get in trouble if a teacher sees him. You tell the monitor what happened. She thanks you both and goes to talk to Marcus. Sam says, 'I never thought of just walking to a teacher. I always just stood there.' Sometimes the simplest plan is the best one.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You and Sam walked away together to find help. Sam said he never thought of that before. Why do you think Sam always 'just stood there'? How can you help someone see options they cannot see when they are scared?",
          learning_points: [
            "Walking toward an adult is one of the simplest and most effective responses to bullying",
            "When you are scared, it is hard to think of options. A friend can help you see them.",
            "Bullies usually will not follow you toward a teacher",
            "Having a plan before bullying happens makes it easier to act in the moment"
          ]
        }
      }
    }
  end
end
