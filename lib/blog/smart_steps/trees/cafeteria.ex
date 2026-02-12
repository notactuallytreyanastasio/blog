defmodule Blog.SmartSteps.Trees.Cafeteria do
  alias Blog.SmartSteps.Types.{ScenarioTree, Scenario, Choice}

  def tree do
    %ScenarioTree{
      id: "cafeteria",
      title: "The Cafeteria",
      description:
        "You are eating lunch in the cafeteria when you hear a group of kids at the next table laughing. You think they might be laughing at you. How do you handle this social situation?",
      theme: :social_misunderstanding,
      age_range: "6-12",
      estimated_minutes: 10,
      start_scenario_id: "caf-start",
      scenarios: %{
        "caf-start" => %Scenario{
          id: "caf-start",
          tree_id: "cafeteria",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :social_misunderstanding,
          level: 1,
          title: "Laughter at Lunch",
          description:
            "You are sitting at your usual spot in the cafeteria, eating your sandwich. You like this spot because it is near the window. Suddenly, a group of kids at the next table starts laughing really loudly. One of them looks in your direction. Your stomach drops. Are they laughing at you?",
          choices: [
            %Choice{
              id: "caf-c1-assume",
              text: "They are definitely laughing at you. Get up and leave.",
              next_scenario_id: "caf-leave",
              risk_level: :high,
              consequence_hint: "Jumping to conclusions"
            },
            %Choice{
              id: "caf-c1-listen",
              text: "Try to listen to what they are actually laughing about",
              next_scenario_id: "caf-listen",
              risk_level: :low,
              consequence_hint: "Gather more information"
            },
            %Choice{
              id: "caf-c1-ask-friend",
              text: "Ask your friend sitting next to you if they heard what the kids said",
              next_scenario_id: "caf-ask-friend",
              risk_level: :low,
              consequence_hint: "Check with someone you trust"
            },
            %Choice{
              id: "caf-c1-confront",
              text: "Walk over and say, 'What are you laughing at?'",
              next_scenario_id: "caf-confront",
              risk_level: :high,
              consequence_hint: "Confrontation without information"
            }
          ],
          image_color: "#FFEE58"
        },
        "caf-leave" => %Scenario{
          id: "caf-leave",
          tree_id: "cafeteria",
          location: "Cafeteria Hallway",
          location_category: :hallway,
          theme: :social_misunderstanding,
          level: 2,
          title: "Walking Away",
          description:
            "You grab your lunch bag and leave the table quickly. Your friend calls after you, 'Hey, where are you going?' You do not answer. You feel hot and embarrassed. You end up standing in the hallway by yourself. Your lunch is only half eaten.",
          choices: [
            %Choice{
              id: "caf-c2-hallway-stay",
              text: "Stay in the hallway and eat alone",
              next_scenario_id: "caf-eat-alone",
              risk_level: :medium,
              consequence_hint: "Isolating yourself"
            },
            %Choice{
              id: "caf-c2-go-back",
              text: "Take a deep breath and go back to your seat",
              next_scenario_id: "caf-return",
              risk_level: :low,
              consequence_hint: "Give it another try"
            },
            %Choice{
              id: "caf-c2-find-teacher",
              text: "Go find a teacher to talk to",
              next_scenario_id: "caf-teacher",
              risk_level: :low,
              consequence_hint: "Seek adult support"
            }
          ],
          image_color: "#EC407A"
        },
        "caf-listen" => %Scenario{
          id: "caf-listen",
          tree_id: "cafeteria",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :social_misunderstanding,
          level: 2,
          title: "Listening Closely",
          description:
            "You pause and listen. The kids are talking about a funny video one of them watched last night. One kid is acting out a scene where a dog steals a pizza, and everyone is cracking up. They were not looking at you at all. The kid just happened to turn their head in your direction.",
          choices: [
            %Choice{
              id: "caf-c3-relieved",
              text: "Feel relieved and go back to eating your lunch",
              next_scenario_id: "caf-relieved",
              risk_level: :low,
              consequence_hint: "Crisis averted"
            },
            %Choice{
              id: "caf-c3-still-unsure",
              text: "You heard them, but you still feel uneasy. Maybe they were laughing at you before?",
              next_scenario_id: "caf-still-worried",
              risk_level: :medium,
              consequence_hint: "Hard to let go of the feeling"
            }
          ],
          image_color: "#66BB6A"
        },
        "caf-ask-friend" => %Scenario{
          id: "caf-ask-friend",
          tree_id: "cafeteria",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :social_misunderstanding,
          level: 2,
          title: "Checking With a Friend",
          description:
            "You lean over to your friend Maya and whisper, 'Are those kids laughing at me?' Maya looks over at the other table and then back at you. 'No way,' she says. 'They are laughing about some video. I heard them talking about it earlier.' She smiles at you. 'You are fine.'",
          choices: [
            %Choice{
              id: "caf-c4-trust-friend",
              text: "Believe Maya and feel better. Keep eating.",
              next_scenario_id: "caf-trust-friend-end",
              risk_level: :low,
              consequence_hint: "Trust your friend"
            },
            %Choice{
              id: "caf-c4-not-sure",
              text: "Say 'Are you sure?' because it really felt like they were looking at you",
              next_scenario_id: "caf-double-check",
              risk_level: :medium,
              consequence_hint: "Still not convinced"
            }
          ],
          image_color: "#42A5F5"
        },
        "caf-confront" => %Scenario{
          id: "caf-confront",
          tree_id: "cafeteria",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :social_misunderstanding,
          level: 2,
          title: "Face to Face",
          description:
            "You walk over to the other table and say, 'What are you laughing at?' The kids look surprised. One of them says, 'Uh, we were talking about a funny video. Why?' They look confused. Another kid whispers something to their friend and they look uncomfortable. Now everyone is staring at you.",
          choices: [
            %Choice{
              id: "caf-c5-explain",
              text: "Say, 'Oh, sorry. I thought you were laughing at me.'",
              next_scenario_id: "caf-honest-explain",
              risk_level: :low,
              consequence_hint: "Be honest about the misunderstanding"
            },
            %Choice{
              id: "caf-c5-double-down",
              text: "Say, 'Well it looked like you were!' and cross your arms",
              next_scenario_id: "caf-escalate",
              risk_level: :high,
              consequence_hint: "Making things worse"
            },
            %Choice{
              id: "caf-c5-walk-away-silent",
              text: "Turn around and walk away without saying anything",
              next_scenario_id: "caf-silent-retreat",
              risk_level: :medium,
              consequence_hint: "Awkward exit"
            }
          ],
          image_color: "#EC407A"
        },
        "caf-eat-alone" => %Scenario{
          id: "caf-eat-alone",
          tree_id: "cafeteria",
          location: "Hallway",
          location_category: :hallway,
          theme: :social_misunderstanding,
          level: 3,
          title: "Lunch Alone in the Hall",
          description:
            "You sit on the floor in the hallway and eat the rest of your sandwich. It is quiet here, but it feels lonely. A teacher walks by and asks why you are not in the cafeteria. You shrug. She says, 'You need to eat in the cafeteria. Come on, I will walk with you.' You missed most of lunch and your friend is probably wondering what happened.",
          choices: [],
          image_color: "#9b59b6",
          is_game_over: true,
          outcome_type: :negative,
          discussion_prompt:
            "You left because you thought kids were laughing at you, but you did not check if that was true. How did leaving make you feel? What could you do differently next time you think someone is laughing at you?",
          learning_points: [
            "Our brains sometimes guess wrong about what other people are thinking",
            "Leaving a situation without checking the facts can make us feel worse",
            "It is okay to feel upset, but checking before reacting helps",
            "Eating alone when you do not have to can make lonely feelings grow"
          ]
        },
        "caf-return" => %Scenario{
          id: "caf-return",
          tree_id: "cafeteria",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :social_misunderstanding,
          level: 3,
          title: "Going Back",
          description:
            "You take a deep breath and walk back into the cafeteria. Your friend waves at you. 'Where did you go?' she asks. The group at the other table is still laughing and talking. They do not even notice you came back. They were never paying attention to you at all.",
          choices: [
            %Choice{
              id: "caf-c6-tell-friend",
              text: "Tell your friend, 'I thought those kids were laughing at me, but I think I was wrong.'",
              next_scenario_id: "caf-share-feeling-end",
              risk_level: :low,
              consequence_hint: "Be honest with your friend"
            },
            %Choice{
              id: "caf-c6-say-nothing",
              text: "Say, 'Just needed some air,' and keep eating",
              next_scenario_id: "caf-quiet-return-end",
              risk_level: :low,
              consequence_hint: "Keep it to yourself for now"
            }
          ],
          image_color: "#42A5F5"
        },
        "caf-teacher" => %Scenario{
          id: "caf-teacher",
          tree_id: "cafeteria",
          location: "Hallway",
          location_category: :hallway,
          theme: :social_misunderstanding,
          level: 3,
          title: "Talking to a Teacher",
          description:
            "You find your favorite teacher, Ms. Johnson, in the hallway. You tell her, 'Some kids in the cafeteria were laughing at me.' She listens carefully and says, 'That must have felt awful. Did you hear what they were saying?' You realize you did not actually hear their words. She says, 'Sometimes our brain tells us something is about us when it is not. Would you like to go back together and see?'",
          choices: [
            %Choice{
              id: "caf-c7-go-with-teacher",
              text: "Go back to the cafeteria with Ms. Johnson",
              next_scenario_id: "caf-teacher-support-end",
              risk_level: :low,
              consequence_hint: "Adult support helps"
            },
            %Choice{
              id: "caf-c7-stay-out",
              text: "Say you would rather stay out here for the rest of lunch",
              next_scenario_id: "caf-avoid-end",
              risk_level: :medium,
              consequence_hint: "Avoiding the situation"
            }
          ],
          image_color: "#42A5F5"
        },
        "caf-relieved" => %Scenario{
          id: "caf-relieved",
          tree_id: "cafeteria",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :social_misunderstanding,
          level: 3,
          title: "It Was Not About You",
          description:
            "You feel a wave of relief wash over you. They were laughing at a silly dog video, not at you. You go back to eating your sandwich and even smile a little when you hear one of the kids say, 'And then the dog grabbed the WHOLE pizza!' That is pretty funny. Your friend starts telling you about her weekend and lunch feels normal again.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You paused and listened before reacting. How did checking the facts change the situation? What would have happened if you had not listened?",
          learning_points: [
            "Pausing to gather information before reacting is a powerful skill",
            "Laughter near you does not always mean laughter about you",
            "Checking the facts can save you from unnecessary worry",
            "Your first thought about a situation is not always the correct one"
          ]
        },
        "caf-still-worried" => %Scenario{
          id: "caf-still-worried",
          tree_id: "cafeteria",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :social_misunderstanding,
          level: 3,
          title: "The Worry Stays",
          description:
            "Even though you heard them talking about a video, the worried feeling will not go away. Your brain keeps saying, 'But what if they WERE laughing at you before?' You pick at your food and cannot enjoy it. Your friend notices you seem quiet and asks, 'Hey, are you okay?'",
          choices: [
            %Choice{
              id: "caf-c8-tell-worry",
              text: "Tell your friend about the worried feeling",
              next_scenario_id: "caf-share-worry-end",
              risk_level: :low,
              consequence_hint: "Share what you are feeling"
            },
            %Choice{
              id: "caf-c8-say-fine",
              text: "Say 'I am fine' even though you are not",
              next_scenario_id: "caf-pretend-fine-end",
              risk_level: :medium,
              consequence_hint: "Hiding your feelings"
            }
          ],
          image_color: "#FFEE58"
        },
        "caf-trust-friend-end" => %Scenario{
          id: "caf-trust-friend-end",
          tree_id: "cafeteria",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :social_misunderstanding,
          level: 3,
          title: "Trusting Your Friend",
          description:
            "You believe Maya and feel the knot in your stomach loosen. 'Thanks,' you say. She nods and starts talking about the book she is reading. The rest of lunch is normal and even fun. By the time the bell rings, you have almost forgotten about the laughing. You are really glad you asked Maya instead of guessing on your own.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "Maya helped you understand what was really happening. Why is it helpful to check with a trusted friend when you are not sure about a social situation?",
          learning_points: [
            "Trusted friends can help you see situations more clearly",
            "Asking someone you trust is a great way to check your thinking",
            "You do not have to figure out confusing social moments alone",
            "Believing a friend's honest answer can help the worried feeling go away"
          ]
        },
        "caf-double-check" => %Scenario{
          id: "caf-double-check",
          tree_id: "cafeteria",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :social_misunderstanding,
          level: 3,
          title: "Needing More Reassurance",
          description:
            "Maya looks at you more seriously. 'I am positive,' she says. 'I promise they are not laughing at you. They were talking about that video all morning.' She puts her hand on your arm. 'I would tell you if they were being mean. That is what friends are for.' You feel a little better, but the uncomfortable feeling takes time to fade.",
          choices: [],
          image_color: "#42A5F5",
          is_game_over: true,
          outcome_type: :neutral,
          discussion_prompt:
            "Even after Maya reassured you, the worried feeling did not go away right away. Is it normal for worried feelings to stick around even when you know the truth? What can help?",
          learning_points: [
            "Worried feelings do not always go away instantly, and that is normal",
            "Sometimes you need to hear reassurance more than once",
            "Having a friend who is patient with you is really valuable",
            "Over time, practicing checking the facts helps worry shrink faster"
          ]
        },
        "caf-honest-explain" => %Scenario{
          id: "caf-honest-explain",
          tree_id: "cafeteria",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :social_misunderstanding,
          level: 3,
          title: "Being Honest",
          description:
            "You say, 'Oh, sorry. I thought you were laughing at me.' The kid shakes their head. 'No! We were watching this hilarious video. Want to see it?' They show you the video on their tablet. It IS really funny. You laugh a little. 'Sorry about that,' you say. 'No worries,' they say. You walk back to your table feeling much better.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You were brave enough to admit you made a mistake. How did the other kids react when you were honest? What does this tell you about being open with people?",
          learning_points: [
            "Being honest about a misunderstanding can turn an awkward moment around",
            "Most people are understanding when you explain how you felt",
            "Admitting you made a mistake shows maturity and courage",
            "Sometimes a misunderstanding can even lead to a new connection"
          ]
        },
        "caf-escalate" => %Scenario{
          id: "caf-escalate",
          tree_id: "cafeteria",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :social_misunderstanding,
          level: 3,
          title: "Things Get Worse",
          description:
            "You cross your arms and say, 'Well it looked like you were!' The kids start looking annoyed. One of them says, 'We were not even talking about you. Why are you being weird?' Another kid laughs nervously. A lunch monitor walks over and says, 'What is going on here?' Now you are in trouble and feeling embarrassed. The monitor asks you to sit at a different table to cool down.",
          choices: [],
          image_color: "#EC407A",
          is_game_over: true,
          outcome_type: :negative,
          discussion_prompt:
            "You were sure they were laughing at you, and even when they explained, you did not believe them. What happens when we hold onto a wrong idea even after getting new information?",
          learning_points: [
            "Doubling down when you are wrong makes situations worse, not better",
            "When someone explains themselves, try to listen with an open mind",
            "Being called 'weird' hurts, but the confrontation made things harder",
            "It is okay to be wrong. Everyone misreads situations sometimes."
          ]
        },
        "caf-silent-retreat" => %Scenario{
          id: "caf-silent-retreat",
          tree_id: "cafeteria",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :social_misunderstanding,
          level: 3,
          title: "The Silent Walk Back",
          description:
            "You turn around without saying anything and walk back to your seat. The other kids exchange confused looks. Your friend asks what happened. You feel embarrassed that you went over there. The rest of lunch is quiet and uncomfortable. You keep replaying the moment in your head.",
          choices: [],
          image_color: "#FFEE58",
          is_game_over: true,
          outcome_type: :neutral,
          discussion_prompt:
            "Walking away silently left things unresolved. How do you think the other kids felt? What could you have said to make the moment less awkward?",
          learning_points: [
            "Walking away without explaining can leave everyone confused",
            "A quick 'my mistake' can fix an awkward moment",
            "It is normal to feel embarrassed, but a small explanation helps",
            "Unresolved moments tend to replay in your mind more than resolved ones"
          ]
        },
        "caf-share-feeling-end" => %Scenario{
          id: "caf-share-feeling-end",
          tree_id: "cafeteria",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :social_misunderstanding,
          level: 4,
          title: "Sharing the Misunderstanding",
          description:
            "You tell your friend, 'I thought those kids were laughing at me, but I think I was wrong.' Your friend says, 'Oh that would be stressful! But I think they are just being silly about some video. It happens to me sometimes too. I think someone is talking about me but they are not.' It feels really good to know you are not the only one who feels that way.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You were honest with your friend about what you thought was happening. Your friend said it happens to them too. Why does it help to know other people have the same experience?",
          learning_points: [
            "Misreading social situations happens to everyone, not just you",
            "Sharing your worries with a friend can make them feel smaller",
            "Coming back after leaving takes courage, and that is worth being proud of",
            "Talking about misunderstandings helps you learn from them"
          ]
        },
        "caf-quiet-return-end" => %Scenario{
          id: "caf-quiet-return-end",
          tree_id: "cafeteria",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :social_misunderstanding,
          level: 4,
          title: "Keeping It Inside",
          description:
            "You say, 'Just needed some air,' and go back to eating. Your friend accepts that answer and starts talking about something else. The rest of lunch is fine, but you still feel a little off inside. You handled it, though. You came back, and the world did not end. Maybe next time you can try talking about what you felt.",
          choices: [],
          image_color: "#42A5F5",
          is_game_over: true,
          outcome_type: :neutral,
          discussion_prompt:
            "You came back, which was great. But you kept the worry to yourself. What might happen if you shared how you were feeling? Is it always better to share, or is it sometimes okay to keep things inside?",
          learning_points: [
            "Coming back to a situation you left is a brave and important step",
            "It is okay to not share everything right away",
            "Sometimes we need time before we are ready to talk about feelings",
            "Over time, practicing sharing can make it easier and more helpful"
          ]
        },
        "caf-share-worry-end" => %Scenario{
          id: "caf-share-worry-end",
          tree_id: "cafeteria",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :social_misunderstanding,
          level: 4,
          title: "The Worry Gets Smaller",
          description:
            "You tell your friend, 'I heard those kids laughing and I thought it was about me. I know it was about a video, but I still feel worried.' Your friend says, 'I get that. Sometimes my brain does that too. Like it gets stuck on the bad thought even when I know it is not true.' Hearing that makes you feel less alone. The worried feeling starts to shrink.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You named the worried feeling even though you knew the facts. Why is it important to talk about feelings even when you logically know everything is okay?",
          learning_points: [
            "Naming a feeling out loud can help it lose its power",
            "Worry can stick around even after you learn the truth, and that is normal",
            "Friends who understand sticky thoughts can help you feel less alone",
            "Telling someone about a worry is not being dramatic. It is being brave."
          ]
        },
        "caf-pretend-fine-end" => %Scenario{
          id: "caf-pretend-fine-end",
          tree_id: "cafeteria",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :social_misunderstanding,
          level: 4,
          title: "Fine on the Outside",
          description:
            "You say 'I am fine' and your friend goes back to eating. But inside, the worried feeling stays with you for the rest of the day. During math class, you keep thinking about it. 'Were they really laughing at me?' The worry grows bigger because you never let it out.",
          choices: [],
          image_color: "#FFEE58",
          is_game_over: true,
          outcome_type: :negative,
          discussion_prompt:
            "You said you were fine, but you were not. The worry stayed with you all day. What happens when we keep worried feelings locked inside? What could help you let them out?",
          learning_points: [
            "Saying 'I am fine' when you are not can make worries grow bigger",
            "Worries that stay inside tend to follow you around all day",
            "It is okay to say, 'Actually, I am a little worried about something'",
            "Trusted people want to help, but they need to know something is wrong"
          ]
        },
        "caf-teacher-support-end" => %Scenario{
          id: "caf-teacher-support-end",
          tree_id: "cafeteria",
          location: "Cafeteria",
          location_category: :cafeteria,
          theme: :social_misunderstanding,
          level: 4,
          title: "Supported by an Adult",
          description:
            "Ms. Johnson walks with you back to the cafeteria. She helps you look at the situation calmly. The kids at the other table are still joking around and do not even notice you. 'See?' she says gently. 'They were just having fun. Your brain jumped to a conclusion. That happens to lots of people.' She helps you sit down and you finish your lunch. It feels good to have an adult who understands.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "Ms. Johnson helped you see the situation differently. What did she mean when she said 'your brain jumped to a conclusion'? Has your brain ever done that before?",
          learning_points: [
            "Adults can help you see social situations from a different angle",
            "Jumping to conclusions means deciding something is true without enough evidence",
            "Asking for help is a sign of strength, especially when your brain feels stuck",
            "Having a trusted adult at school makes hard moments easier to handle"
          ]
        },
        "caf-avoid-end" => %Scenario{
          id: "caf-avoid-end",
          tree_id: "cafeteria",
          location: "Hallway",
          location_category: :hallway,
          theme: :social_misunderstanding,
          level: 4,
          title: "Avoiding the Cafeteria",
          description:
            "You tell Ms. Johnson you would rather stay in the hallway. She lets you sit in her classroom for the rest of lunch. It is quiet and calm, but you missed out on being with your friend. The next day, you feel nervous about going back to the cafeteria. Avoiding it once makes it harder to go back.",
          choices: [],
          image_color: "#9b59b6",
          is_game_over: true,
          outcome_type: :negative,
          discussion_prompt:
            "Avoiding the cafeteria felt safer in the moment, but it made the next day harder. Why does avoiding something scary make it scarier over time? What small step could help you go back?",
          learning_points: [
            "Avoiding things that scare us can make the fear grow bigger",
            "Each time you avoid something, it gets harder to face it next time",
            "Taking small steps back into a scary situation builds confidence",
            "A trusted adult can help you practice going back gradually"
          ]
        }
      }
    }
  end
end
