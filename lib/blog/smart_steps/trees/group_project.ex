defmodule Blog.SmartSteps.Trees.GroupProject do
  alias Blog.SmartSteps.Types.{ScenarioTree, Scenario, Choice}

  def tree do
    %ScenarioTree{
      id: "group-project",
      title: "The Group Project",
      description:
        "Your teacher assigns a group project. The group picks an unfamiliar topic and everyone talks at once. How do you participate and share your ideas?",
      theme: :group_participation,
      age_range: "6-12",
      estimated_minutes: 10,
      start_scenario_id: "group-project-start",
      scenarios: %{
        "group-project-start" => %Scenario{
          id: "group-project-start",
          tree_id: "group-project",
          location: "Classroom",
          location_category: :classroom,
          theme: :group_participation,
          level: 1,
          title: "Group Assignment",
          description:
            "Your teacher says, 'Today we are starting a group project! I have assigned you to groups of four.' You look at your group: there is Mia, who talks a lot; Tyler, who is really bossy; and Lily, who is quiet like you. The teacher says to pick a topic for your project. Mia immediately starts suggesting ideas. Tyler talks over her. Everyone is speaking at once.",
          choices: [
            %Choice{
              id: "gp-c1-quiet",
              text: "Stay quiet and wait for them to figure it out",
              next_scenario_id: "group-project-quiet",
              risk_level: :medium,
              consequence_hint: "Your ideas go unheard"
            },
            %Choice{
              id: "gp-c1-speak",
              text: "Raise your hand and say, 'I have an idea too'",
              next_scenario_id: "group-project-speak-up",
              risk_level: :low,
              consequence_hint: "Share your voice"
            },
            %Choice{
              id: "gp-c1-write",
              text: "Write your idea on paper and slide it to the group",
              next_scenario_id: "group-project-write",
              risk_level: :low,
              consequence_hint: "Communicate in your own way"
            },
            %Choice{
              id: "gp-c1-teacher",
              text: "Go to the teacher and ask if you can work alone instead",
              next_scenario_id: "group-project-ask-alone",
              risk_level: :medium,
              consequence_hint: "Avoid the group"
            }
          ],
          image_color: "#FFEE58"
        },
        "group-project-quiet" => %Scenario{
          id: "group-project-quiet",
          tree_id: "group-project",
          location: "Classroom",
          location_category: :classroom,
          theme: :group_participation,
          level: 2,
          title: "Sitting Silent",
          description:
            "You sit quietly while Mia and Tyler argue about the topic. Lily looks at you and shrugs. After five minutes, Tyler decides for the whole group: 'We are doing volcanoes.' You actually know a lot about space and would have loved that topic, but nobody asked you.",
          choices: [
            %Choice{
              id: "gp-c2-accept",
              text: "Accept the volcano topic and try to make the best of it",
              next_scenario_id: "group-project-accept-topic",
              risk_level: :medium,
              consequence_hint: "Go along with it"
            },
            %Choice{
              id: "gp-c2-speak-now",
              text: "Say, 'Wait, I really wanted to suggest space. Can we vote?'",
              next_scenario_id: "group-project-suggest-vote",
              risk_level: :low,
              consequence_hint: "Speak up before it is too late"
            },
            %Choice{
              id: "gp-c2-shut-down",
              text: "Put your head down. You are frustrated nobody asked you.",
              next_scenario_id: "group-project-shut-down",
              risk_level: :high,
              consequence_hint: "Withdrawing"
            }
          ],
          image_color: "#42A5F5"
        },
        "group-project-speak-up" => %Scenario{
          id: "group-project-speak-up",
          tree_id: "group-project",
          location: "Classroom",
          location_category: :classroom,
          theme: :group_participation,
          level: 2,
          title: "Your Voice Matters",
          description:
            "You raise your hand and say, 'I have an idea too.' Tyler says, 'Okay, what?' You suggest doing the project on space. Mia says, 'Ooh, that could be cool!' Tyler shrugs. Lily nods enthusiastically. The group decides to vote between the ideas.",
          choices: [
            %Choice{
              id: "gp-c3-vote",
              text: "Suggest everyone writes their top choice on a piece of paper",
              next_scenario_id: "group-project-fair-vote",
              risk_level: :low,
              consequence_hint: "Fair process"
            },
            %Choice{
              id: "gp-c3-combine",
              text: "Suggest combining ideas: 'What about volcanoes in space?'",
              next_scenario_id: "group-project-combine",
              risk_level: :low,
              consequence_hint: "Creative compromise"
            }
          ],
          image_color: "#66BB6A"
        },
        "group-project-write" => %Scenario{
          id: "group-project-write",
          tree_id: "group-project",
          location: "Classroom",
          location_category: :classroom,
          theme: :group_participation,
          level: 2,
          title: "Written Words",
          description:
            "You write on a piece of paper: 'How about space? I know a lot about planets.' You slide it across the table. Mia reads it out loud. 'Oh, that is a great idea!' Tyler looks at the paper and says, 'Why did you not just say that?' Lily writes on her own paper: 'I like the paper idea. Can we all write our ideas down?'",
          choices: [
            %Choice{
              id: "gp-c4-explain",
              text: "Say, 'Sometimes it is easier for me to write than talk in groups.'",
              next_scenario_id: "group-project-explain",
              risk_level: :low,
              consequence_hint: "Self-advocacy"
            },
            %Choice{
              id: "gp-c4-ignore-tyler",
              text: "Ignore Tyler's comment and say, 'Great, let us all write our ideas!'",
              next_scenario_id: "group-project-all-write",
              risk_level: :low,
              consequence_hint: "Move forward positively"
            }
          ],
          image_color: "#66BB6A"
        },
        "group-project-ask-alone" => %Scenario{
          id: "group-project-ask-alone",
          tree_id: "group-project",
          location: "Teacher's Desk",
          location_category: :classroom,
          theme: :group_participation,
          level: 2,
          title: "Asking the Teacher",
          description:
            "You walk to the teacher's desk. 'Can I work alone? Groups are really hard for me.' The teacher nods understandingly. 'I know groups can be challenging. How about this: you stay in the group but I will give you a specific job so you know exactly what to do. Would that help?'",
          choices: [
            %Choice{
              id: "gp-c5-try",
              text: "Say, 'Okay, I will try that.'",
              next_scenario_id: "group-project-specific-role",
              risk_level: :low,
              consequence_hint: "Structured support"
            },
            %Choice{
              id: "gp-c5-refuse",
              text: "Say, 'No, I really cannot do groups. Please let me work alone.'",
              next_scenario_id: "group-project-alone-end",
              risk_level: :medium,
              consequence_hint: "Avoiding the challenge"
            }
          ],
          image_color: "#42A5F5"
        },
        "group-project-accept-topic" => %Scenario{
          id: "group-project-accept-topic",
          tree_id: "group-project",
          location: "Classroom",
          location_category: :classroom,
          theme: :group_participation,
          level: 3,
          title: "Making the Best of It",
          description:
            "You decide to go with the volcano topic. Tyler starts assigning jobs. 'I will do the poster, Mia will write the report, and you two can... do whatever.' He did not give you or Lily a real job. You feel invisible.",
          choices: [
            %Choice{
              id: "gp-c6-ask-job",
              text: "Say, 'I would like to do the research part. I am good at finding facts.'",
              next_scenario_id: "group-project-claim-role",
              risk_level: :low,
              consequence_hint: "Advocate for a role"
            },
            %Choice{
              id: "gp-c6-let-it-go",
              text: "Do not say anything. Just do whatever Tyler tells you.",
              next_scenario_id: "group-project-invisible-end",
              risk_level: :high,
              consequence_hint: "Giving up your voice"
            }
          ],
          image_color: "#FFEE58"
        },
        "group-project-suggest-vote" => %Scenario{
          id: "group-project-suggest-vote",
          tree_id: "group-project",
          location: "Classroom",
          location_category: :classroom,
          theme: :group_participation,
          level: 3,
          title: "Calling for a Vote",
          description:
            "You speak up: 'Wait, I really wanted to suggest space. Can we vote?' Tyler rolls his eyes, but Mia says, 'That is fair.' Everyone votes. Space wins 3-1! Tyler is a little grumpy but goes along with it. You feel proud that you spoke up and the group listened.",
          choices: [
            %Choice{
              id: "gp-c7-include-tyler",
              text: "Ask Tyler what part of the project he wants to do, so he feels included",
              next_scenario_id: "group-project-teamwork",
              risk_level: :low,
              consequence_hint: "Good leadership"
            }
          ],
          image_color: "#66BB6A"
        },
        "group-project-shut-down" => %Scenario{
          id: "group-project-shut-down",
          tree_id: "group-project",
          location: "Classroom",
          location_category: :classroom,
          theme: :group_participation,
          level: 3,
          title: "Shutting Down",
          description:
            "You put your head on the desk. The group ignores you and keeps working. When the teacher comes to check on your group, she notices you are not participating. 'Are you okay?' she asks quietly. The others stare at you. You feel embarrassed and frustrated.",
          choices: [
            %Choice{
              id: "gp-c8-tell-teacher",
              text: "Whisper to the teacher, 'Nobody asked for my ideas and I feel left out.'",
              next_scenario_id: "group-project-teacher-helps",
              risk_level: :low,
              consequence_hint: "Ask for help"
            },
            %Choice{
              id: "gp-c8-say-fine",
              text: "Say, 'I am fine,' and keep your head down",
              next_scenario_id: "group-project-withdraw-end",
              risk_level: :high,
              consequence_hint: "Staying stuck"
            }
          ],
          image_color: "#9b59b6"
        },
        "group-project-fair-vote" => %Scenario{
          id: "group-project-fair-vote",
          tree_id: "group-project",
          location: "Classroom",
          location_category: :classroom,
          theme: :group_participation,
          level: 3,
          title: "A Fair System",
          description:
            "Everyone writes their choice on paper. You count the votes: space gets three, volcanoes gets one. 'Space wins!' Mia announces. Even Tyler says, 'Okay, that was fair.' Lily smiles at you. Your idea of a written vote made sure everyone's voice was heard, including the quiet ones.",
          choices: [
            %Choice{
              id: "gp-c9-assign",
              text: "Suggest everyone picks the part of the project they are best at",
              next_scenario_id: "group-project-teamwork",
              risk_level: :low,
              consequence_hint: "Play to strengths"
            }
          ],
          image_color: "#66BB6A"
        },
        "group-project-combine" => %Scenario{
          id: "group-project-combine",
          tree_id: "group-project",
          location: "Classroom",
          location_category: :classroom,
          theme: :group_participation,
          level: 3,
          title: "Best of Both Worlds",
          description:
            "You suggest, 'What about volcanoes in space? Mars has the biggest volcano in the solar system!' Everyone's eyes light up. Tyler says, 'Wait, really? That is actually awesome.' Mia starts writing notes. Lily looks up facts on the class tablet. By combining ideas, everyone got what they wanted and the project is even more interesting.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You combined two ideas to create something even better. How does it feel when everyone's ideas get included? Why is compromise sometimes better than winning?",
          learning_points: [
            "Combining ideas can create something better than either idea alone",
            "Compromise means everyone gets something they care about",
            "Creative thinking can solve disagreements",
            "When everyone contributes, the result is stronger"
          ]
        },
        "group-project-explain" => %Scenario{
          id: "group-project-explain",
          tree_id: "group-project",
          location: "Classroom",
          location_category: :classroom,
          theme: :group_participation,
          level: 3,
          title: "Explaining Your Way",
          description:
            "You say, 'Sometimes it is easier for me to write things down than say them out loud in a group.' Tyler looks confused but Mia nods. 'That makes sense! My older sister is like that too.' The teacher overhears and says, 'That is great self-advocacy. The group can use written ideas as a method.' From then on, everyone writes their thoughts down first, and it actually helps the whole group focus.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You told your group that you communicate better in writing, and it ended up helping everyone. When have you explained something about yourself that surprised people?",
          learning_points: [
            "Explaining how you work best is powerful self-advocacy",
            "Your way of communicating is valid and can help others too",
            "When you share your needs, people often understand",
            "Different does not mean wrong. It can mean better."
          ]
        },
        "group-project-all-write" => %Scenario{
          id: "group-project-all-write",
          tree_id: "group-project",
          location: "Classroom",
          location_category: :classroom,
          theme: :group_participation,
          level: 3,
          title: "Everyone Writes",
          description:
            "You say, 'Great, let us all write our ideas down!' Everyone grabs paper. For the first time, the table is quiet as people think and write. When you share the papers, you have four great ideas. Tyler says, 'This is actually way better than arguing.' Lily smiles at you gratefully. Your idea changed how the whole group works.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "By suggesting everyone write ideas down, you helped the loud AND quiet people share equally. How can changing the way a group communicates make it fairer?",
          learning_points: [
            "Different methods of sharing ideas can help everyone participate",
            "Quiet people often have the best ideas but need a way to share them",
            "Changing the process can be more effective than changing yourself",
            "Your needs can inspire solutions that help everyone"
          ]
        },
        "group-project-specific-role" => %Scenario{
          id: "group-project-specific-role",
          tree_id: "group-project",
          location: "Classroom",
          location_category: :classroom,
          theme: :group_participation,
          level: 3,
          title: "Your Special Job",
          description:
            "The teacher gives you the job of 'Research Expert.' You are in charge of finding all the facts the group needs. This is perfect because you love looking things up! You go back to the group and say, 'The teacher made me the researcher. What facts do you need?' Tyler actually looks relieved. 'Great, can you find out how volcanoes erupt?'",
          choices: [
            %Choice{
              id: "gp-c10-research",
              text: "Dive into the research happily. This is what you are good at!",
              next_scenario_id: "group-project-expert-end",
              risk_level: :low,
              consequence_hint: "Play to your strength"
            }
          ],
          image_color: "#66BB6A"
        },
        "group-project-alone-end" => %Scenario{
          id: "group-project-alone-end",
          tree_id: "group-project",
          location: "Classroom Corner",
          location_category: :classroom,
          theme: :group_participation,
          level: 3,
          title: "Working Alone",
          description:
            "The teacher lets you work alone. You do a great job on your project by yourself, but you notice the other groups laughing and sharing ideas. Part of you feels relieved, but part of you wonders what it would have been like to be part of the team. Lily looks over at you sadly. She is stuck with Tyler and Mia without a quiet ally.",
          choices: [],
          image_color: "#42A5F5",
          is_game_over: true,
          outcome_type: :neutral,
          discussion_prompt:
            "Working alone was easier, but you missed out on the teamwork experience and left Lily without support. What is one small way you could try groups next time?",
          learning_points: [
            "Avoiding hard things keeps us comfortable but limits our growth",
            "Other quiet people might need you in the group",
            "Groups are hard, but they get easier with practice and support",
            "Asking for accommodations (like a specific role) is better than avoiding entirely"
          ]
        },
        "group-project-claim-role" => %Scenario{
          id: "group-project-claim-role",
          tree_id: "group-project",
          location: "Classroom",
          location_category: :classroom,
          theme: :group_participation,
          level: 4,
          title: "Claiming Your Place",
          description:
            "You say, 'I would like to do the research. I am really good at finding facts.' Tyler looks surprised but says, 'Okay, fine.' Lily adds, 'And I will do the drawings.' Now everyone has a real job. You feel much better having a clear role. When you bring back amazing facts, Tyler says, 'Wow, you are really good at this.'",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "You asked for a role that matched your strengths. How did having a specific job help you feel more comfortable in the group?",
          learning_points: [
            "Asking for a role that fits your strengths helps you contribute",
            "You do not have to be loud to be valuable in a group",
            "Knowing what you are good at is a skill",
            "When everyone has a clear role, groups work better"
          ]
        },
        "group-project-invisible-end" => %Scenario{
          id: "group-project-invisible-end",
          tree_id: "group-project",
          location: "Classroom",
          location_category: :classroom,
          theme: :group_participation,
          level: 4,
          title: "The Invisible Member",
          description:
            "You go along with whatever Tyler says. By the end of the project, your name is on it but you barely contributed. The teacher asks you about it privately. 'It looked like you did not do much in the group. Was everything okay?' You feel ashamed, but the truth is nobody gave you a chance and you did not ask for one.",
          choices: [],
          image_color: "#EC407A",
          is_game_over: true,
          outcome_type: :negative,
          discussion_prompt:
            "You were part of the group but did not really participate. Whose responsibility was it: the group's for not including you, or yours for not speaking up? Maybe both?",
          learning_points: [
            "Not speaking up can leave you feeling invisible and frustrated",
            "You deserve a role in the group, but sometimes you have to claim it",
            "It is okay to ask the teacher for help if the group is not working",
            "Silence is not the same as being okay"
          ]
        },
        "group-project-teamwork" => %Scenario{
          id: "group-project-teamwork",
          tree_id: "group-project",
          location: "Classroom",
          location_category: :classroom,
          theme: :group_participation,
          level: 4,
          title: "Real Teamwork",
          description:
            "Everyone picks their part: you do research, Mia writes, Tyler designs the poster, and Lily draws the illustrations. Each person works on their strength. When you put it all together, it is the best project in the class. The teacher says, 'This is what great teamwork looks like.' Your group high-fives. Even Tyler smiles at you.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "When everyone played to their strengths, the project was amazing. What are YOUR strengths that you bring to a group? How can you make sure they get used?",
          learning_points: [
            "Every person has strengths that matter in a group",
            "The best teams let each person do what they do best",
            "Speaking up about your strengths helps the whole team",
            "Group projects can be great when everyone has a clear role"
          ]
        },
        "group-project-teacher-helps" => %Scenario{
          id: "group-project-teacher-helps",
          tree_id: "group-project",
          location: "Classroom",
          location_category: :classroom,
          theme: :group_participation,
          level: 4,
          title: "Teacher Steps In",
          description:
            "You whisper to the teacher that you feel left out. She nods and goes to the group. 'Let me check in. Has everyone shared an idea?' Tyler and Mia look at each other. 'Um, not everyone,' Mia admits. The teacher says, 'Let us hear from everyone before we decide.' Now it is your turn. The group listens, and your idea about space gets included.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "Asking the teacher for help was not tattling. It was self-advocacy. How is asking for help different from complaining? When should you ask an adult to step in?",
          learning_points: [
            "Asking for help when you are being excluded is the right thing to do",
            "Teachers want to help but cannot always see what is happening",
            "Whispering to the teacher is a safe way to advocate for yourself",
            "Self-advocacy means making sure your voice gets heard"
          ]
        },
        "group-project-withdraw-end" => %Scenario{
          id: "group-project-withdraw-end",
          tree_id: "group-project",
          location: "Classroom",
          location_category: :classroom,
          theme: :group_participation,
          level: 4,
          title: "Checked Out",
          description:
            "You keep your head down for the rest of the work time. The group finishes without you. When the project is presented, you stand at the back and say nothing. You get a lower grade because you did not participate. You feel frustrated because you had great ideas, but you never shared them. The ideas stayed locked inside.",
          choices: [],
          image_color: "#EC407A",
          is_game_over: true,
          outcome_type: :negative,
          discussion_prompt:
            "You had great ideas but kept them inside. What got in the way of sharing them? What could make it safer for you to share ideas in a group next time?",
          learning_points: [
            "Shutting down means your great ideas stay hidden",
            "It is okay to ask for a different way to share, like writing",
            "Asking the teacher for help before you shut down is important",
            "Everyone's ideas have value, including yours"
          ]
        },
        "group-project-expert-end" => %Scenario{
          id: "group-project-expert-end",
          tree_id: "group-project",
          location: "Classroom",
          location_category: :classroom,
          theme: :group_participation,
          level: 4,
          title: "The Research Expert",
          description:
            "You dive into the research and find amazing facts that nobody else knew. When you present your findings to the group, everyone is impressed. 'How did you find all this?' Mia asks. 'You are like a detective!' Tyler adds. Having a clear role let you shine. You contributed more than anyone expected, including yourself.",
          choices: [],
          image_color: "#66BB6A",
          is_game_over: true,
          outcome_type: :positive,
          discussion_prompt:
            "Having a specific role helped you participate without the stress of the chaotic group discussion. What roles work best for you in group settings?",
          learning_points: [
            "Clear roles reduce stress and help everyone contribute",
            "Playing to your strengths is not cheating. It is smart.",
            "Asking the teacher for support showed self-awareness",
            "You can be a valuable team member in your own way"
          ]
        }
      }
    }
  end
end
