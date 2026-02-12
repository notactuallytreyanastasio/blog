defmodule Blog.SmartSteps.Trees.SubstituteTeacher do
  alias Blog.SmartSteps.Types.{ScenarioTree, Scenario, Choice}

  def tree do
    %ScenarioTree{
      id: "substitute-teacher",
      title: "The Substitute Teacher",
      description:
        "You arrive at school and discover your regular teacher is absent. A substitute teacher who does not know your classroom routine is in charge today. How do you handle this unexpected change?",
      theme: :transitions,
      age_range: "6-12",
      estimated_minutes: 10,
      start_scenario_id: "sub-start",
      scenarios: %{
        "sub-start" => %Scenario{
          id: "sub-start",
          tree_id: "substitute-teacher",
          location: "Classroom Doorway",
          location_category: :classroom,
          theme: :transitions,
          level: 1,
          title: "A Different Face",
          description:
            "You walk into your classroom and freeze. Your teacher, Mr. Garcia, is not at his desk. Instead, there is someone you have never seen before. She is writing her name on the board: 'Ms. Taylor.' Your seat has been moved, there are no name tags on the desks, and the daily schedule on the board looks completely different. Everything feels wrong.",
          choices: [
            %Choice{
              id: "sub-c1-refuse",
              text: "Stand in the doorway and refuse to go in",
              next_scenario_id: "sub-refuse-enter",
              risk_level: :high,
              consequence_hint: "The change is too much"
            },
            %Choice{
              id: "sub-c1-find-seat",
              text: "Walk in and try to find where your desk went",
              next_scenario_id: "sub-find-seat",
              risk_level: :low,
              consequence_hint: "Figure it out"
            },
            %Choice{
              id: "sub-c1-ask-sub",
              text: "Raise your hand and tell the substitute your desk is not where it should be",
              next_scenario_id: "sub-ask-teacher",
              risk_level: :low,
              consequence_hint: "Advocate for yourself"
            },
            %Choice{
              id: "sub-c1-office",
              text: "Turn around and walk to the main office",
              next_scenario_id: "sub-go-office",
              risk_level: :medium,
              consequence_hint: "Seek help elsewhere"
            }
          ],
          image_color: "#FFEE58"
        },
        "sub-refuse-enter" => %Scenario{
          id: "sub-refuse-enter",
          tree_id: "substitute-teacher",
          location: "Classroom Doorway",
          location_category: :classroom,
          theme: :transitions,
          level: 2,
          title: "Stuck at the Door",
          description:
            "You stand in the doorway. Other kids squeeze past you. Ms. Taylor notices and walks over. 'Hi there! I am Ms. Taylor, your substitute for today. Come on in!' But your feet will not move. This is not how the day is supposed to start. Your heart is beating fast.",
          choices: [
            %Choice{
              id: "sub-c2-explain",
              text: "Tell Ms. Taylor, 'I need a minute. Changes are hard for me.'",
              next_scenario_id: "sub-explain-needs",
              risk_level: :low,
              consequence_hint: "Use your words"
            },
            %Choice{
              id: "sub-c2-cry",
              text: "Start to get upset. Your eyes fill with tears.",
              next_scenario_id: "sub-overwhelmed",
              risk_level: :high,
              consequence_hint: "Emotions are overwhelming"
            },
            %Choice{
              id: "sub-c2-buddy",
              text: "Look for your friend in the classroom and go sit near them",
              next_scenario_id: "sub-find-buddy",
              risk_level: :low,
              consequence_hint: "Find an anchor"
            }
          ],
          image_color: "#EC407A"
        },
        "sub-find-seat" => %Scenario{
          id: "sub-find-seat",
          tree_id: "substitute-teacher",
          location: "Classroom",
          location_category: :classroom,
          theme: :transitions,
          level: 2,
          title: "Where Is My Desk?",
          description:
            "You walk into the room and look around. The desks are rearranged into groups instead of rows. You cannot find your name anywhere. You sit in what looks like it might be near where your desk used to be, but a classmate says, 'Hey, Ms. Taylor said we have new seats today.' Everything about the room feels different.",
          choices: [
            %Choice{
              id: "sub-c3-ask-where",
              text: "Ask Ms. Taylor where you should sit",
              next_scenario_id: "sub-new-seat",
              risk_level: :low,
              consequence_hint: "Get the information you need"
            },
            %Choice{
              id: "sub-c3-argue",
              text: "Say, 'This is not how Mr. Garcia does it. I sit HERE.'",
              next_scenario_id: "sub-argue-seat",
              risk_level: :high,
              consequence_hint: "Resisting the change"
            },
            %Choice{
              id: "sub-c3-quiet-sit",
              text: "Stay quiet and sit wherever there is an empty chair",
              next_scenario_id: "sub-wrong-spot",
              risk_level: :medium,
              consequence_hint: "Going along without asking"
            }
          ],
          image_color: "#42A5F5"
        },
        "sub-ask-teacher" => %Scenario{
          id: "sub-ask-teacher",
          tree_id: "substitute-teacher",
          location: "Classroom",
          location_category: :classroom,
          theme: :transitions,
          level: 2,
          title: "Speaking Up",
          description:
            "You raise your hand and Ms. Taylor comes over. You say, 'My desk is not where it usually is. Mr. Garcia has a seating chart in his desk drawer.' Ms. Taylor smiles. 'Thank you so much for telling me that! I did not know. Let me find it.' She opens the drawer and pulls out the seating chart. 'You are very helpful,' she says.",
          choices: [
            %Choice{
              id: "sub-c4-help-more",
              text: "Offer to help Ms. Taylor set up the room the right way",
              next_scenario_id: "sub-helper-role",
              risk_level: :low,
              consequence_hint: "Your knowledge is valuable"
            },
            %Choice{
              id: "sub-c4-just-sit",
              text: "Find your seat and settle in. You feel a little better now.",
              next_scenario_id: "sub-settle-in",
              risk_level: :low,
              consequence_hint: "One problem solved"
            }
          ],
          image_color: "#66BB6A"
        },
        "sub-go-office" => %Scenario{
          id: "sub-go-office",
          tree_id: "substitute-teacher",
          location: "Main Office",
          location_category: :hallway,
          theme: :transitions,
          level: 2,
          title: "At the Office",
          description:
            "You walk to the main office. The secretary looks up and says, 'Aren't you supposed to be in class?' You say, 'Mr. Garcia is not there. There is a different teacher.' The secretary nods. 'That is Ms. Taylor, the substitute. Mr. Garcia is sick today, but he will be back tomorrow. You need to go to class now.'",
          choices: [
            %Choice{
              id: "sub-c5-go-back",
              text: "Walk back to class now that you know Mr. Garcia is coming back tomorrow",
              next_scenario_id: "sub-informed-return",
              risk_level: :low,
              consequence_hint: "Information helped"
            },
            %Choice{
              id: "sub-c5-ask-stay",
              text: "Ask the secretary if you can stay in the office instead",
              next_scenario_id: "sub-avoid-class",
              risk_level: :medium,
              consequence_hint: "Trying to avoid the change"
            }
          ],
          image_color: "#42A5F5"
        },
        "sub-explain-needs" => %Scenario{
          id: "sub-explain-needs",
          tree_id: "substitute-teacher",
          location: "Classroom Doorway",
          location_category: :classroom,
          theme: :transitions,
          level: 3,
          title: "Asking for What You Need",
          description:
            "You tell Ms. Taylor, 'I need a minute. Changes are hard for me.' She looks at you kindly and says, 'Take your time. There is no rush. When you are ready, your seat is over by the window.' She does not make a big deal of it. She just goes back to helping other kids. After a minute, your breathing slows down and you walk to your seat.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You told the substitute teacher exactly what you needed. How did it feel when she listened and did not rush you? Why is it important to tell new people what helps you?",
          learning_points: [
            "Telling people what you need is called self-advocacy, and it is a superpower",
            "Most adults will respect your needs if you explain them clearly",
            "New people cannot know your needs unless you share them",
            "Taking a minute to adjust is completely okay"
          ]
        },
        "sub-overwhelmed" => %Scenario{
          id: "sub-overwhelmed",
          tree_id: "substitute-teacher",
          location: "Hallway",
          location_category: :hallway,
          theme: :transitions,
          level: 3,
          title: "The Feelings Spill Over",
          description:
            "Tears start rolling down your cheeks. Ms. Taylor looks worried and is not sure what to do. She says, 'Oh! Are you okay? What is wrong?' Some kids in the class look over at you. You feel embarrassed on top of upset. The school counselor happens to walk by and gently takes you to a quiet spot in the hallway. 'I can see this is a hard morning,' she says.",
          choices: [
            %Choice{
              id: "sub-c6-talk-counselor",
              text: "Tell the counselor that you did not know there would be a substitute",
              next_scenario_id: "sub-counselor-help-end",
              risk_level: :low,
              consequence_hint: "Let an adult help"
            },
            %Choice{
              id: "sub-c6-shut-down",
              text: "You cannot talk right now. You just need to be quiet.",
              next_scenario_id: "sub-quiet-time-end",
              risk_level: :medium,
              consequence_hint: "Need time to reset"
            }
          ],
          image_color: "#9b59b6"
        },
        "sub-find-buddy" => %Scenario{
          id: "sub-find-buddy",
          tree_id: "substitute-teacher",
          location: "Classroom",
          location_category: :classroom,
          theme: :transitions,
          level: 3,
          title: "Finding a Friend",
          description:
            "You spot your friend Jayden near the window. You walk over and sit in the empty chair next to him. 'Can you believe we have a sub?' he says. 'I hope she is nice.' Just being near someone familiar makes the room feel a little less strange. Ms. Taylor starts the day by introducing herself and going over the schedule.",
          choices: [
            %Choice{
              id: "sub-c7-listen-schedule",
              text: "Listen carefully to the new schedule",
              next_scenario_id: "sub-adapt-end",
              risk_level: :low,
              consequence_hint: "Getting information helps"
            },
            %Choice{
              id: "sub-c7-compare",
              text: "Whisper to Jayden, 'This is all wrong. She is doing everything different.'",
              next_scenario_id: "sub-compare-struggle",
              risk_level: :medium,
              consequence_hint: "Focusing on differences"
            }
          ],
          image_color: "#42A5F5"
        },
        "sub-new-seat" => %Scenario{
          id: "sub-new-seat",
          tree_id: "substitute-teacher",
          location: "Classroom",
          location_category: :classroom,
          theme: :transitions,
          level: 3,
          title: "A Temporary Spot",
          description:
            "Ms. Taylor shows you a seat in a group with three other kids. It is not your usual spot, but you can see the board from here. 'This is just for today,' she says. 'Your regular teacher will put things back when he returns.' Knowing it is temporary makes it a little easier to handle. You sit down and put your things away.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You asked for help and learned the new arrangement was just for one day. How does knowing something is temporary make it easier to handle? What other changes in life are temporary?",
          learning_points: [
            "Asking for information helps you understand a confusing situation",
            "Knowing a change is temporary makes it easier to cope with",
            "Flexibility is a skill you can practice, and it gets easier over time",
            "Even when things are different, you can still have a good day"
          ]
        },
        "sub-argue-seat" => %Scenario{
          id: "sub-argue-seat",
          tree_id: "substitute-teacher",
          location: "Classroom",
          location_category: :classroom,
          theme: :transitions,
          level: 3,
          title: "Refusing the New Setup",
          description:
            "You tell Ms. Taylor firmly, 'This is not how Mr. Garcia does it. I sit HERE.' Ms. Taylor looks uncomfortable. 'I understand this is different,' she says, 'but for today, I need you to sit where I assigned you.' Other kids are watching. You feel your face getting hot. The more you insist, the more attention you are getting.",
          choices: [
            %Choice{
              id: "sub-c8-give-in",
              text: "Take a deep breath and go to the new seat, even though you do not like it",
              next_scenario_id: "sub-reluctant-sit-end",
              risk_level: :low,
              consequence_hint: "Compromise"
            },
            %Choice{
              id: "sub-c8-refuse-more",
              text: "Sit in your old spot anyway and refuse to move",
              next_scenario_id: "sub-defiant-end",
              risk_level: :critical,
              consequence_hint: "Full resistance"
            }
          ],
          image_color: "#EC407A"
        },
        "sub-wrong-spot" => %Scenario{
          id: "sub-wrong-spot",
          tree_id: "substitute-teacher",
          location: "Classroom",
          location_category: :classroom,
          theme: :transitions,
          level: 3,
          title: "The Wrong Chair",
          description:
            "You sit in an empty chair quietly, hoping no one will notice. But a few minutes later, another student comes in and says, 'That is my seat.' Ms. Taylor looks confused. 'Does anyone know where this student sits?' she asks the class. A classmate points to a seat across the room. You have to get up and move in front of everyone.",
          choices: [],
          image_color: "#FFEE58",
          is_game_over: true,
          outcome_type: :neutral,
          discussion_prompt:
            "You tried to avoid asking for help, but it led to an uncomfortable moment. What would have happened if you had asked the substitute where to sit from the start?",
          learning_points: [
            "Asking questions early can prevent awkward moments later",
            "It is better to ask for help than to guess and hope for the best",
            "Substitutes do not know your routine unless you tell them",
            "Speaking up for yourself saves time and stress in the long run"
          ]
        },
        "sub-helper-role" => %Scenario{
          id: "sub-helper-role",
          tree_id: "substitute-teacher",
          location: "Classroom",
          location_category: :classroom,
          theme: :transitions,
          level: 3,
          title: "The Expert Helper",
          description:
            "You help Ms. Taylor find the seating chart, show her where the supplies are kept, and explain the morning routine. 'You are like my assistant teacher today!' she says, smiling. The other kids see you helping and the day starts to feel more normal. You realize that YOU know more about this classroom than Ms. Taylor does. That makes you feel confident instead of scared.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You turned a scary situation into one where you were the expert! How did helping the substitute teacher change how you felt about the day? Can knowing a lot about something give you confidence?",
          learning_points: [
            "Your knowledge of routines can actually be a strength in new situations",
            "Helping others can shift your feelings from anxious to confident",
            "Being the person who knows the routine makes you valuable to the group",
            "Change can be an opportunity to show what you know"
          ]
        },
        "sub-settle-in" => %Scenario{
          id: "sub-settle-in",
          tree_id: "substitute-teacher",
          location: "Classroom",
          location_category: :classroom,
          theme: :transitions,
          level: 3,
          title: "One Step at a Time",
          description:
            "You find your seat and sit down. It is still not a normal day, but you got past the first hard part. Ms. Taylor writes the schedule on the board, and even though it is a little different from Mr. Garcia's schedule, most of the subjects are the same. You take it one step at a time. By lunchtime, you have settled in.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You handled the surprise of a substitute teacher by solving one problem at a time. What was the first problem you solved? How did solving it help you handle the rest of the day?",
          learning_points: [
            "Big changes feel smaller when you handle them one step at a time",
            "Solving the first small problem builds confidence for the next one",
            "The information you shared helped both you and the substitute",
            "Most substitute days turn out okay, even when they start off scary"
          ]
        },
        "sub-informed-return" => %Scenario{
          id: "sub-informed-return",
          tree_id: "substitute-teacher",
          location: "Classroom",
          location_category: :classroom,
          theme: :transitions,
          level: 3,
          title: "Knowing Helps",
          description:
            "You walk back to class knowing that Mr. Garcia will be back tomorrow. That one piece of information makes everything feel a little better. You walk in, find an empty seat, and sit down. Ms. Taylor is going over the day's plan. It is different from normal, but you keep telling yourself: 'Just one day. Mr. Garcia will be back tomorrow.'",
          choices: [],
          image_color: "#42A5F5",
          is_game_over: true,
          outcome_type: :neutral,
          discussion_prompt:
            "Knowing that Mr. Garcia would be back tomorrow helped you cope. Why does having information about a change make it easier? What questions could you ask next time something unexpected happens?",
          learning_points: [
            "Information reduces uncertainty, and uncertainty is what makes change scary",
            "Asking 'when will things go back to normal?' is a great coping question",
            "It is okay to seek reassurance when something unexpected happens",
            "Temporary changes are easier to handle when you know the timeline"
          ]
        },
        "sub-avoid-class" => %Scenario{
          id: "sub-avoid-class",
          tree_id: "substitute-teacher",
          location: "Main Office",
          location_category: :hallway,
          theme: :transitions,
          level: 3,
          title: "Avoiding the Classroom",
          description:
            "You ask the secretary if you can stay in the office. She shakes her head gently. 'I know it is hard with a substitute, but you need to be in class. I will walk you back.' She walks you to the classroom door. You missed the first fifteen minutes, and Ms. Taylor has already started the lesson. You have to figure out what is going on while everyone else already knows.",
          choices: [],
          image_color: "#EC407A",
          is_game_over: true,
          outcome_type: :negative,
          discussion_prompt:
            "You tried to avoid the classroom, but you ended up missing part of the day. How did missing the beginning make things harder? What could you do next time to face the change earlier?",
          learning_points: [
            "Avoiding a change often makes the situation harder, not easier",
            "Showing up late means you miss information that could help you",
            "The sooner you face something uncomfortable, the sooner you can adjust",
            "It is okay to ask for support, but staying in the situation helps you grow"
          ]
        },
        "sub-counselor-help-end" => %Scenario{
          id: "sub-counselor-help-end",
          tree_id: "substitute-teacher",
          location: "Hallway",
          location_category: :hallway,
          theme: :transitions,
          level: 4,
          title: "The Counselor Understands",
          description:
            "You tell the counselor, 'No one told me there would be a substitute. Everything in the room is different.' She nods. 'That sounds really overwhelming when you are not expecting it. Let us make a plan. I will talk to Ms. Taylor and let her know what helps you. And next time Mr. Garcia is going to be out, I will make sure someone tells you the day before.' You feel heard and cared for.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "The counselor made a plan to warn you next time. Why is it helpful to have a plan for unexpected changes? What would you want to know ahead of time?",
          learning_points: [
            "Adults can create plans to help you with transitions if you tell them what you need",
            "Being warned about a change ahead of time makes it much easier to handle",
            "Crying or getting upset does not mean you failed. It means you need support.",
            "A good plan turns a crisis into something manageable"
          ]
        },
        "sub-quiet-time-end" => %Scenario{
          id: "sub-quiet-time-end",
          tree_id: "substitute-teacher",
          location: "Hallway",
          location_category: :hallway,
          theme: :transitions,
          level: 4,
          title: "Quiet Reset",
          description:
            "The counselor sits with you in the quiet spot and does not push you to talk. After a few minutes, your breathing calms down. She says, 'Whenever you are ready, we can go back to class together. No rush.' You sit for five more minutes, then nod. She walks you back and quietly tells Ms. Taylor to give you some space. The rest of the day is hard, but you get through it.",
          choices: [],
          image_color: "#42A5F5",
          is_game_over: true,
          outcome_type: :neutral,
          discussion_prompt:
            "You needed quiet time to reset before you could go back to class. Is needing quiet time a problem, or is it a way of taking care of yourself? What does a good reset look like for you?",
          learning_points: [
            "Needing time to reset is a healthy way to manage overwhelm",
            "A calm adult who does not rush you can make a big difference",
            "Getting through a hard day, even imperfectly, is still a success",
            "Knowing your reset strategies ahead of time makes them easier to use"
          ]
        },
        "sub-adapt-end" => %Scenario{
          id: "sub-adapt-end",
          tree_id: "substitute-teacher",
          location: "Classroom",
          location_category: :classroom,
          theme: :transitions,
          level: 4,
          title: "Adapting to the Day",
          description:
            "You listen as Ms. Taylor goes over the schedule. Reading is first instead of math. Art is after lunch instead of before. It is different, but you write it down so you know what to expect. Having it written down helps. By the end of the day, Ms. Taylor says, 'You all did great today!' You survived a substitute day, and it was not as bad as you thought.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You listened to the new schedule and wrote it down. How did having information help you adapt? What tools or strategies help you handle changes in routine?",
          learning_points: [
            "Writing things down gives your brain something solid to hold onto",
            "A different schedule is not a wrong schedule. It is just different.",
            "Finding a friend to sit near can make unfamiliar situations feel safer",
            "Most substitute days end better than they start"
          ]
        },
        "sub-compare-struggle" => %Scenario{
          id: "sub-compare-struggle",
          tree_id: "substitute-teacher",
          location: "Classroom",
          location_category: :classroom,
          theme: :transitions,
          level: 4,
          title: "Stuck on the Differences",
          description:
            "You spend the whole morning whispering to Jayden about everything Ms. Taylor does differently. 'Mr. Garcia does not do it that way,' you keep saying. By lunchtime, you are frustrated and tired. You have not really learned anything because you were so focused on what was wrong. Jayden says, 'I get it, but I think she is doing okay. It is just one day.'",
          choices: [],
          image_color: "#FFEE58",
          is_game_over: true,
          outcome_type: :negative,
          discussion_prompt:
            "You spent the day focused on everything that was different instead of trying to work with it. How did focusing on the differences make you feel? What could help you accept changes even when you do not like them?",
          learning_points: [
            "Focusing on what is wrong can make a manageable day feel miserable",
            "Different does not always mean bad. It just means unfamiliar.",
            "Accepting a temporary change uses less energy than fighting it all day",
            "Your friend Jayden showed you that a different perspective can help"
          ]
        },
        "sub-reluctant-sit-end" => %Scenario{
          id: "sub-reluctant-sit-end",
          tree_id: "substitute-teacher",
          location: "Classroom",
          location_category: :classroom,
          theme: :transitions,
          level: 4,
          title: "Going Along Reluctantly",
          description:
            "You do not like it, but you take a deep breath and walk to the new seat. It feels wrong, but you sit down. Ms. Taylor says, 'Thank you.' As the morning goes on, you realize the seat is actually near the art supplies, which is kind of nice. It is not your usual spot, but you managed. Mr. Garcia will put things back tomorrow.",
          choices: [],
          image_color: "#42A5F5",
          is_game_over: true,
          outcome_type: :neutral,
          discussion_prompt:
            "You did not want to move, but you did. How did it feel to do something you did not want to do? Did the new seat turn out to be as bad as you expected?",
          learning_points: [
            "Doing something you do not want to do can take a lot of courage",
            "Sometimes things we resist turn out to be okay or even good",
            "Flexibility does not mean you like the change. It means you can handle it.",
            "Being able to compromise is a skill that gets easier with practice"
          ]
        },
        "sub-defiant-end" => %Scenario{
          id: "sub-defiant-end",
          tree_id: "substitute-teacher",
          location: "Classroom",
          location_category: :classroom,
          theme: :transitions,
          level: 4,
          title: "The Standoff",
          description:
            "You sit in your old spot and refuse to move. Ms. Taylor asks you again, then again. Other kids are staring. Finally, she calls the office and the assistant principal comes to the room. You are asked to step into the hallway. You end up spending the first hour in the office instead of in class. The change was hard, but fighting it made the day much harder.",
          choices: [],
          image_color: "#EC407A",
          is_game_over: true,
          outcome_type: :severe,
          discussion_prompt:
            "Refusing to move led to a bigger problem. The change felt unbearable, but what happened because of the refusal? What could you ask for next time to make a change like this more manageable?",
          learning_points: [
            "Refusing to cooperate can turn a small problem into a much bigger one",
            "It is okay to be upset about a change, but there are better ways to express it",
            "Asking for help or a compromise works better than refusing completely",
            "A plan for substitute days can prevent this kind of crisis"
          ]
        }
      }
    }
  end
end
