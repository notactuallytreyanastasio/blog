defmodule BlogWeb.NathanAsciiLive do
  use BlogWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Nathan Fielder: ASCII Character Study")}
  end

  def render(assigns) do
    ~H"""
    <div class="nathan-ascii-container">
      <div class="ascii-content">
        <pre class="ascii-text"><%= raw(nathan_fielder_ascii()) %></pre>
      </div>
    </div>

    <style>
      .nathan-ascii-container {
        width: 100%;
        display: flex;
        justify-content: center;
        padding: 2rem 1rem;
        background-color: #000;
        min-height: 100vh;
      }

      .ascii-content {
        width: 80%;
        max-width: none;
        overflow-x: auto;
      }

      .ascii-text {
        font-family: 'Courier New', 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
        font-size: 14px;
        line-height: 1.2;
        color: #00ff00;
        background-color: #000;
        margin: 0;
        padding: 1rem;
        white-space: pre;
        overflow-x: auto;
        word-wrap: break-word;
        border: 2px solid #00ff00;
        border-radius: 4px;
      }

      /* Hide scrollbars for a cleaner look */
      .ascii-content::-webkit-scrollbar,
      .ascii-text::-webkit-scrollbar {
        height: 8px;
      }

      .ascii-content::-webkit-scrollbar-track,
      .ascii-text::-webkit-scrollbar-track {
        background: #000;
      }

      .ascii-content::-webkit-scrollbar-thumb,
      .ascii-text::-webkit-scrollbar-thumb {
        background: #00ff00;
        border-radius: 4px;
      }

      .ascii-content::-webkit-scrollbar-thumb:hover,
      .ascii-text::-webkit-scrollbar-thumb:hover {
        background: #00cc00;
      }

      /* Responsive adjustments */
      @media (max-width: 768px) {
        .ascii-content {
          width: 95%;
        }
        
        .ascii-text {
          font-size: 12px;
          padding: 0.5rem;
        }
      }

      /* Override any global styles */
      body {
        background-color: #000 !important;
      }
    </style>
    """
  end

  defp nathan_fielder_ascii do
    """
    ################################################################################
    #                                                                              #
    #                              NATHAN FIELDER                                  #
    #                                                                              #
    ################################################################################

    ┌─────────────────────────────────────────────────────────────────────────────┐
    │ What happens when someone's coping mechanism becomes so complete that it    │
    │ replaces the person who needed to cope?                                     │
    └─────────────────────────────────────────────────────────────────────────────┘

    Nathan Fielder is a bit of an enigma. If you have watched Nathan For You, The
    Rehearsal, or The Curse, you know that he has a very specific brand of comedy
    that is very strange and uncomfortable to many. He plays a character on the
    level of Andy Kaufman, and in this piece we will dissect his history, his
    character, and what all this really means if anything at all.

    Note: We refer to Nathan Fielder as AMNF (Actual Man Nathan Fielder) and his
    character as CNF (Character Nathan Fielder)

    ═══════════════════════════════════════════════════════════════════════════════
    ▶ INTRODUCTION
    ═══════════════════════════════════════════════════════════════════════════════

    What started as some business consulting segments turned into one of the
    weirdest examinations of identity and comedy and human experience that I have
    ever seen. Here I try to break down the arc of Actual Man Nathan Fielder as he
    becomes Character Nathan Fielder and leans in further, and look at if he is
    actually just a character to himself.

    ┌─────────────────────────────────────────────────────────────────────────────┐
    │ ASIDE: The Kaufman Connection - Two People, or, how many, really?          │
    ├─────────────────────────────────────────────────────────────────────────────┤
    │                                                                             │
    │ The Andy Kaufman Template                                                   │
    │ ────────────────────────                                                   │
    │                                                                             │
    │ Andy Kaufman (1949-1984) created a performance methodology built around    │
    │ incredulity - making audiences question everything they thought they knew   │
    │ about entertainment, reality, and human behavior. His Foreign Man          │
    │ character, Tony Clifton persona, and elaborate wrestling stunts weren't    │
    │ just comedy bits; they were systematic attacks on the audience's           │
    │ expectations of what performance should be.                                 │
    │                                                                             │
    │ Kaufman's Core Strategy: Use performance to create a space where social    │
    │ rules don't apply, where he could interact with the world through          │
    │ constructed characters that allowed him to navigate situations his         │
    │ authentic self found difficult or impossible.                              │
    │                                                                             │
    │ The Nathan Evolution                                                        │
    │ ──────────────────                                                         │
    │                                                                             │
    │ Andy's Approach:                                                            │
    │ • Character Types: Foreign Man (childlike confusion), Tony Clifton         │
    │   (aggressive confidence), wrestling personas (physical dominance)         │
    │ • Audience Relationship: Deliberate confusion and discomfort. "Is this     │
    │   real? Is he serious? What's happening?"                                  │
    │ • Never Breaking: Maintained characters even in "private" interviews,      │
    │   making reality/performance indistinguishable                             │
    │ • Social Navigation: Characters provided frameworks for interaction that   │
    │   his neurodivergent authentic self couldn't manage                        │
    │                                                                             │
    │ Nathan's Approach:                                                          │
    │ • Character Types: Business consultant (competent authority), helpful      │
    │   friend (genuine concern), performance artist (committed experimenter)    │
    │ • Audience Relationship: Elaborate scenarios that blur help/exploitation.  │
    │   "Is he helping? Is this real? Should I feel bad for laughing?"           │
    │ • Never Breaking: Maintains deadpan consultant persona even when schemes   │
    │   become absurd (alligators, tightrope training, child actors)             │
    │ • Social Navigation: Elaborate constructions become his primary interface  │
    │   with human connection and authentic experience                            │
    │                                                                             │
    │ ┌─ The Neurodivergent Framework ─────────────────────────────────────────┐ │
    │ │                                                                         │ │
    │ │ Masking Through Performance: Both Andy and Nathan seem to use their     │ │
    │ │ characters as sophisticated masking strategies. Where most              │ │
    │ │ neurodivergent people learn to "act normal," they learned to act as    │ │
    │ │ constructed personas that could navigate social situations more         │ │
    │ │ effectively than their authentic selves.                               │ │
    │ │                                                                         │ │
    │ │ Obsessive Commitment: The extreme dedication both show to their         │ │
    │ │ constructions - Andy maintaining Tony Clifton for years, Nathan        │ │
    │ │ training months for a tightrope walk - suggests something beyond       │ │
    │ │ comedy. It's the same hyperfocus that characterizes neurodivergent     │ │
    │ │ special interests, but applied to identity construction.               │ │
    │ │                                                                         │ │
    │ │ Reality as Performance Space: Both treat the "real world" as a stage   │ │
    │ │ where they can experiment with different approaches to human           │ │
    │ │ connection. Nathan's parenting rehearsals and elaborate business       │ │
    │ │ schemes echo Andy's wrestling personas and Foreign Man interactions -  │ │
    │ │ attempts to find a version of themselves that can successfully connect │ │
    │ │ with others.                                                           │ │
    │ └─────────────────────────────────────────────────────────────────────────┘ │
    │                                                                             │
    │ ┌─ The Crucial Differences ──────────────────────────────────────────────┐ │
    │ │                                                                         │ │
    │ │ Andy's Characters Were Shields: Foreign Man and Tony Clifton protected │ │
    │ │ Andy from direct social interaction. They were buffers between his     │ │
    │ │ authentic self and a world he found overwhelming.                      │ │
    │ │                                                                         │ │
    │ │ Nathan's Character Is a Bridge: His business consultant persona doesn't │ │
    │ │ protect him from authentic interaction - it facilitates it. Nathan     │ │
    │ │ uses CNF (Character Nathan Fielder) to access human connection that    │ │
    │ │ AMNF (Actual Man Nathan Fielder) cannot reach alone.                   │ │
    │ │                                                                         │ │
    │ │ The Consumption Problem: Andy maintained separation between his         │ │
    │ │ characters and himself until his death. Nathan's character appears to  │ │
    │ │ be consuming his authentic self entirely, raising the question of      │ │
    │ │ whether AMNF will survive the process.                                 │ │
    │ │                                                                         │ │
    │ │ ┌─────────────────────────────────────────────────────────────────────┐ │ │
    │ │ │ Nathan's character appears to be consuming his authentic self       │ │ │
    │ │ │ entirely, raising the question of whether AMNF will survive the     │ │ │
    │ │ │ process.                                                            │ │ │
    │ │ └─────────────────────────────────────────────────────────────────────┘ │ │
    │ └─────────────────────────────────────────────────────────────────────────┘ │
    └─────────────────────────────────────────────────────────────────────────────┘

    ═══════════════════════════════════════════════════════════════════════════════
    ▶ NATHAN FOR YOU: The Establishment of AMNF vs CNF
    ═══════════════════════════════════════════════════════════════════════════════

    ┌─────────────────────────────────────────────────────────────────────────────┐
    │ What It Says It Is         vs.         What It Actually Is                │
    │ ─────────────────                     ─────────────────                    │
    │                                                                             │
    │ 📺 Business Help Show                  🎭 Comedy Central Show             │
    │ Expert arrives to help                 Comedian with business degree       │
    │ struggling small business              suggests absurd solutions           │
    │                                                                             │
    │ Standard format:                       Nathan's format:                    │
    │ consultant analyzes problem →          real problem → ridiculous solution  │
    │ provides solution →                    → commit completely                 │
    │ business improves                                                          │
    └─────────────────────────────────────────────────────────────────────────────┘

    ╔═════════════════════════════════════════════════════════════════════════════╗
    ║ CASE STUDY: The Poop Flavored Yogurt                                       ║
    ╠═════════════════════════════════════════════════════════════════════════════╣
    ║                                                                             ║
    ║ 1. The Problem: Froyo shop needs more customers                            ║
    ║                                                                             ║
    ║ 2. Nathan's Solution: Offer poop-flavored frozen yogurt                    ║
    ║                                                                             ║
    ║ 3. The Commitment: Hires lab to formulate safe poop-tasting formula        ║
    ║                                                                             ║
    ║ 4. The Result: Customers order it, taste it: "This tastes like shit."     ║
    ║    Response: "Well, you did order poop ice cream."                         ║
    ╚═════════════════════════════════════════════════════════════════════════════╝

    ▼ The Evolution of Nathan's Methodology

    ┌─ The Alligator Discount Electronics Store ─────────────────────────────────┐
    │                                                                             │
    │ 1. The Problem: 60-year-old family electronics store being destroyed by    │
    │    Best Buy                                                                 │
    │                                                                             │
    │ 2. Nathan's Solution: Exploit price-matching by advertising TVs for $1     │
    │                                                                             │
    │ 3. The Escalation: Black-tie dress code → 2-foot door → live alligator     │
    │    guardian                                                                 │
    │                                                                             │
    │ 4. The Result: Best Buy refuses match, scheme fails, Nathan sets up owner  │
    │    romantically instead                                                     │
    └─────────────────────────────────────────────────────────────────────────────┘

    ┌─ Seven Months of Tightrope Training ("The Hero") ──────────────────────────┐
    │                                                                             │
    │ 1. The Problem: Corey, 26, lives with grandparents and "glides through     │
    │    life"                                                                    │
    │                                                                             │
    │ 2. Nathan's Solution: Death-defying tightrope walk between 7-story         │
    │    buildings                                                                │
    │                                                                             │
    │ 3. The Commitment: Nathan trains 7 months, creates prosthetic mask, lives  │
    │    as Corey                                                                 │
    │                                                                             │
    │ 4. The Result: Nathan walks the tightrope 6 times; Corey gains confidence  │
    │    and moves out                                                            │
    └─────────────────────────────────────────────────────────────────────────────┘

    ┌─ Dumb Starbucks ───────────────────────────────────────────────────────────┐
    │                                                                             │
    │ 1. The Problem: Elias needs help competing with nearby Starbucks           │
    │                                                                             │
    │ 2. Nathan's Solution: Open "Dumb Starbucks" using parody law as legal      │
    │    protection                                                               │
    │                                                                             │
    │ 3. The Viral Explosion: Store becomes international news, lines around     │
    │    the block                                                                │
    │                                                                             │
    │ 4. Reality Collapse: Health department shuts it down; Nathan's show        │
    │    becomes the news                                                         │
    │                                                                             │
    │ ▶ The Line Obliterated: This episode marks a crucial evolution - Nathan's  │
    │   constructions break containment and become actual cultural events. The   │
    │   show stops being about the show and becomes about reality responding to  │
    │   the show. Is it still comedy when CNN is covering your bit as breaking   │
    │   news?                                                                     │
    └─────────────────────────────────────────────────────────────────────────────┘

    ┌─ Finding Frances: The Series Finale ───────────────────────────────────────┐
    │                                                                             │
    │ 1. The Problem: Bill Heath regrets not marrying Frances Gaddy from the     │
    │    1960s                                                                    │
    │                                                                             │
    │ 2. Nathan's Solution: Multi-state search using fake movie, reunion, age    │
    │    progression technology                                                   │
    │                                                                             │
    │ 3. The Complexity: Rehearsal actress, escort practice sessions, Nathan     │
    │    dating the escort                                                        │
    │                                                                             │
    │ 4. The Result: Frances found, happily married; Bill's fantasies collapse   │
    │    into profound documentary                                                │
    └─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────────────┐
    │ THE PATTERN EMERGES:                                                       │
    │                                                                             │
    │ Start with real problems, apply obsessive logic, commit completely to      │
    │ elaborate execution, then discover that human connection matters more than │
    │ business success. Nathan's schemes function as social experiments exposing │
    │ truths about capitalism, loneliness, and the performances we all enact     │
    │ daily.                                                                      │
    │                                                                             │
    │ The Evolution Timeline: From "The Hunk" establishing fake shows within     │
    │ shows, to "Dumb Starbucks" breaking into reality and becoming actual news, │
    │ to "Smokers Allowed" creating performance-based legal loopholes, to "The   │
    │ Movement" manufacturing actual cultural phenomena, to "The Anecdote"       │
    │ showing Nathan playing Nathan playing Nathan, to "The Richards Tip"        │
    │ demonstrating his willingness to train for months for a single moment -    │
    │ each episode builds Nathan's toolkit for reality manipulation. These       │
    │ aren't just comedy bits; they're experiments in how far constructed        │
    │ reality can intrude upon and reshape actual reality.                       │
    └─────────────────────────────────────────────────────────────────────────────┘

    ▼ Not Typical Cringe Comedy

    Typical Cringe: "I am doing something uncomfortable → you feel uncomfortable
                    → ha ha"

    Nathan's Method: Complete deadpan commitment → pulls strange interactions
                     from real people → genuine confusion/absurdity

    ▼ The Birth of CNF from AMNF

    AMNF (Actual Man Nathan Fielder):
    • Genuine business education from University of Victoria
    • Real social awkwardness
    • Authentic dedication to completing tasks
    • Sincere belief in his problem-solving abilities
                              ↓
    Early CNF (Character Nathan Fielder):
    • AMNF traits amplified for television
    • Awkwardness becomes performance tool
    • Business knowledge weaponized for comedy
    • Commitment becomes extreme dedication to absurdity

    ═══════════════════════════════════════════════════════════════════════════════
    ▶ THE CENTRAL QUESTION: Where Does Nathan End and "Nathan" Begin?
    ═══════════════════════════════════════════════════════════════════════════════

    ╔═════════════════════════════════════════════════════════════════════════════╗
    ║ THE FUNDAMENTAL PROBLEM                                                     ║
    ║                                                                             ║
    ║ Is Nathan playing a character? Or is that just him? When he does press, he  ║
    ║ never breaks character. But what if there's no character to break?          ║
    ╚═════════════════════════════════════════════════════════════════════════════╝

    ▼ The Investigation

    ┌─ Historical Consistency ───────────────────────────────────────────────────┐
    │ People have dug into his past. Pictures of him as an awkward teen look     │
    │ exactly like the way he's awkward now. Same mannerisms, same social        │
    │ positioning, same deadpan delivery.                                        │
    └─────────────────────────────────────────────────────────────────────────────┘

    ┌─ Press Appearances ────────────────────────────────────────────────────────┐
    │ In interviews, podcasts, public appearances - he maintains the exact same  │
    │ persona. No "breaking character" moments, no winking at the audience, no   │
    │ "real Nathan" emerging.                                                     │
    └─────────────────────────────────────────────────────────────────────────────┘

    ┌─ Peer Testimony ───────────────────────────────────────────────────────────┐
    │ People who knew him before fame (including Seth Rogen from high school     │
    │ improv) describe him as essentially the same person he appears to be on    │
    │ screen.                                                                     │
    └─────────────────────────────────────────────────────────────────────────────┘

    ▼ The Deeper Issue

    ┌─ The Paradox ──────────────────────────────────────────────────────────────┐
    │ It seems definitive that he's playing a character. But the "I think"       │
    │ qualifier is still WILD. It's a character that appears to be a very thin   │
    │ augmentation of his actual self.                                            │
    └─────────────────────────────────────────────────────────────────────────────┘

    ┌─ The Identity Problem ─────────────────────────────────────────────────────┐
    │ If you play a character so often and for so long, doesn't that kind of     │
    │ become you? What does it even mean to "be a person" when the performance   │
    │ and the self become indistinguishable?                                     │
    └─────────────────────────────────────────────────────────────────────────────┘

    That these questions are even raised is what makes Nathan's work compelling.
    Even during the original Nathan for You run (2013-2017), these philosophical
    implications were present.

    ▼ The Disappearance

    What happened during the gap? Nathan largely disappeared from public view (at
    least for many viewers). He did some behind-the-scenes work on other people's
    projects, but no major solo work. The questions about his identity and
    performance seemingly went dormant... until they exploded back to life with
    The Rehearsal.

    ┌─────────────────────────────────────────────────────────────────────────────┐
    │ ASIDE: How To with John Wilson - The HBO Connection                        │
    ├─────────────────────────────────────────────────────────────────────────────┤
    │                                                                             │
    │ During this period, Nathan executive produced How To with John Wilson on    │
    │ HBO (2020-2023). This gave him crucial network relationships that would    │
    │ later enable his own HBO projects.                                         │
    │                                                                             │
    │ The Meta-Performance: In this show, we see Nathan (as CNF) advocating      │
    │ publicly for the show he's making as AMNF. He's performing the role of     │
    │ executive producer while simultaneously being an executive producer,       │
    │ creating another layer in the reality/performance distinction.             │
    │                                                                             │
    │ The Bread Scene Paradox: Nathan appears in the episode about bread,        │
    │ ostensibly as "himself" - just Nathan Fielder, executive producer, having  │
    │ a casual conversation. But which Nathan is this? He's being filmed for     │
    │ Wilson's show while potentially being filmed for his own purposes,         │
    │ creating a moment where CNF plays AMNF for someone else's camera while     │
    │ remaining CNF for his own narrative. The simple act of Nathan eating bread │
    │ becomes a philosophical puzzle: is any moment of Nathan on camera ever NOT │
    │ a performance?                                                              │
    │                                                                             │
    │ This connects directly to "The Anecdote" from Nathan For You, where Nathan │
    │ manufactured a story to tell "naturally" on Jimmy Kimmel. The difference   │
    │ is that by the time of the bread scene, the performance has become so      │
    │ total that even mundane moments in other people's projects become part of  │
    │ the CNF construction. There's no longer a clear moment where Nathan stops  │
    │ performing Nathan.                                                          │
    └─────────────────────────────────────────────────────────────────────────────┘

    ═══════════════════════════════════════════════════════════════════════════════
    ▶ THE REHEARSAL - When Performance Becomes Reality
    ═══════════════════════════════════════════════════════════════════════════════

    ▼ The New Premise

    After five years away, Nathan returns with a deceptively simple idea: Big
    moments in life are stressful. What if we could rehearse for them?

    But this isn't really about helping other people anymore. This is Nathan
    trying to figure out how other people approach things in life - how they make
    connections, how they handle difficult conversations, how they navigate
    moments that feel impossible. He's moved from trying not to feel alone to
    actively studying other people to see if he can learn something about being
    human from watching them.

    The sales pitch is the same - it's presented as a helpful show where Nathan
    uses his business background and elaborate methods to solve people's problems.
    But the rehearsals aren't really for them. They're for Nathan. He's creating
    controlled environments where he can observe authentic human behavior, study
    how people connect, and maybe figure out what he's been missing.

    ▼ The Obsessive Detail

    What becomes immediately clear in the first episode is the sheer intensity of
    Nathan's approach. This isn't just "let's practice your conversation" - this
    is laser-scanning apartments to create perfect replicas, hiring actors to
    play every single person who might be present, creating conversation
    flowcharts with multiple branching paths for every possible response.

    The level of detail is almost disturbing in its completeness. Nathan doesn't
    just want to help someone practice telling the truth - he wants to create an
    entire alternate reality where every variable is controlled, every outcome is
    rehearsed, every human interaction is scripted and perfected. The obsession
    with getting every detail exactly right reveals something about Nathan's
    relationship with authenticity: he can only approach real human connection
    through elaborate artifice.

    ▼ The Shift: From Helping Others to Self-Examination

    What begins as helping someone else with their problem gradually becomes
    something else entirely. As the show progresses, it becomes clear that Nathan
    is using "rehearsal" as a vehicle to explore his own questions about identity,
    authenticity, and human connection. The show becomes an ouroboros - Nathan
    rehearsing being Nathan.

    The Core Questions Emerge:
    • What is reality when everything can be perfectly replicated?
    • Who are we when we can rehearse being ourselves?
    • What does it mean to be human when human interaction becomes scripted?
    • If you practice authenticity, does it cease to be authentic?

    ▼ The Evolution from Nathan for You

    The Rehearsal is both very different from Nathan for You and exactly the same.
    The commitment to the bit is still extreme, the deadpan delivery intact, but
    now the "bit" is Nathan's own existence. Where Nathan for You asked "Is Nathan
    playing a character?", The Rehearsal asks "What happens when Nathan uses that
    character to figure out who he really is?"

    ═══════════════════════════════════════════════════════════════════════════════
    ▶ THE COVID PIVOT - When Character Becomes Person
    ═══════════════════════════════════════════════════════════════════════════════

    ▼ The Forced Evolution

    COVID-19 hits during production, fundamentally altering the show's trajectory.
    What was designed as a controlled experiment in rehearsing life becomes an
    uncontrolled experiment in living. The external world forces Nathan to abandon
    his carefully constructed scenarios and confront something more immediate and
    real.

    ▼ The Parenting Rehearsal

    Nathan begins exploring scenarios around family and parenting - territory
    that's deeply personal and impossible to fully script. Unlike business advice
    or social interactions, parenting touches something fundamental about identity,
    legacy, and human connection that can't be reduced to conversation flowcharts.

    ┌─ The Child Actor Rotation ─────────────────────────────────────────────────┐
    │ As Nathan "rehearses" being a father, he works with different child actors │
    │ playing his "son." When one child doesn't fit his vision or becomes        │
    │ unavailable, he brings in another. The children form attachments to Nathan │
    │ as a father figure during their time on the show, then transition out when │
    │ their participation ends.                                                   │
    └─────────────────────────────────────────────────────────────────────────────┘

    ┌─ The Oregon Transportation: Recreating Home ───────────────────────────────┐
    │ Nathan physically transports the replica set from the first episode all    │
    │ the way to Oregon. This constructed environment, originally built to help  │
    │ someone else, becomes a space where Nathan can access authentic emotion    │
    │ and feel at home.                                                           │
    │                                                                             │
    │ The Constructed Comfort: Nathan finds that the artificial environment he   │
    │ built provides him with a sense of home and emotional authenticity that he │
    │ struggles to access elsewhere. The replica becomes more real to him than   │
    │ reality.                                                                    │
    └─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────────────┐
    │ The Intersection of Performance and Development:                            │
    │                                                                             │
    │ Nathan's exploration of parenthood involves real children experiencing     │
    │ genuine relationships within constructed scenarios. These children form    │
    │ authentic attachments while participating in Nathan's identity experiment. │
    │ The question emerges: what happens when someone's psychological            │
    │ exploration becomes another person's formative experience?                 │
    └─────────────────────────────────────────────────────────────────────────────┘

    ▼ The Collapse of AMNF vs CNF

    The Problem: When Nathan starts "rehearsing" being a parent, the distinction
    between his character and himself becomes impossible to maintain. You can't
    fake-parent for an extended period without it affecting who you actually are.

    The Reality: The character changes Nathan experiences while grappling with
    family scenarios are very real. He's not performing fatherhood for comedy -
    he's using the framework of performance to explore genuine questions about
    family, connection, and his own capacity for intimacy.

    The Paradox: Nathan is simultaneously using his show to explore authentic
    human experience while being filmed for television. The most genuine moments
    of self-discovery are happening within the most artificial construct possible.

    ▼ The Complete Ouroboros

    By this point, Nathan isn't helping other people rehearse their lives - he's
    using other people to rehearse his own. The show becomes an investigation into
    Nathan's capacity for authentic human connection, conducted through the most
    inauthentic means possible. The "rehearsal" becomes the reality, and the
    reality becomes impossible to distinguish from performance.

    ┌─────────────────────────────────────────────────────────────────────────────┐
    │ The central question is no longer "Is Nathan playing a character?" but     │
    │ "Can Nathan stop playing a character long enough to figure out who he      │
    │ actually is?"                                                               │
    └─────────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────────────┐
    │ ASIDE: The Curse - Scripted Reality as Performance Art                     │
    ├─────────────────────────────────────────────────────────────────────────────┤
    │                                                                             │
    │ The Format Evolution                                                        │
    │ ──────────────────                                                         │
    │                                                                             │
    │ In 2023, Nathan makes a dramatic departure: The Curse on Showtime and      │
    │ Paramount+. Unlike his previous shows, which existed in reality TV or      │
    │ adjacent spaces, The Curse is a fully scripted series. Co-created and     │
    │ written with Benny Safdie (Uncut Gems), with both of them starring        │
    │ alongside Emma Stone.                                                       │
    │                                                                             │
    │ The Show Within The Show                                                    │
    │ ─────────────────────                                                     │
    │                                                                             │
    │ The Surface Story: Nathan and Emma play a couple who have just landed      │
    │ their own HGTV show called "Fliplanthropy." Set in Española, New Mexico,   │
    │ they're trying to help improve the local economy while building            │
    │ eco-friendly homes.                                                         │
    │                                                                             │
    │ The Uncomfortable Truth: Of course, you could also say they're exploiting  │
    │ the fuck out of a small town to make piles of money. But that's not what   │
    │ they're doing, right? They have GOOD intentions, not bad ones! Other      │
    │ shows do that, but they're not like them. (Benny plays the producer of     │
    │ their HGTV show.)                                                           │
    │                                                                             │
    │ Thematic Explosion                                                          │
    │ ──────────────────                                                         │
    │                                                                             │
    │ According to Wikipedia, the show deals with:                               │
    │ The artifice of reality television, gentrification, cultural appropriation,│
    │ white privilege, Native American rights, sustainable capitalism, Judaism,  │
    │ pathological altruism, virtue signalling, marriage, and parenthood.        │
    │                                                                             │
    │ Three Key Observations:                                                     │
    │ 1. Cinematic Excellence: The cinematography is beautiful and reinforces    │
    │    the storytelling in a way rarely seen on television.                   │
    │                                                                             │
    │ 2. The Meta-Reality Problem: They're making this show in Española (and     │
    │    Santa Fe). The question becomes: Is making a fake show about exploiting │
    │    a small town any different than actually doing so?                      │
    │                                                                             │
    │ 3. Emotional Intensity: The show is emotionally intense and compelling in  │
    │    ways that transcend its meta-commentary. It becomes genuinely affecting │
    │    television while simultaneously deconstructing the very medium it       │
    │    exists within.                                                           │
    │                                                                             │
    │ What This Means for Nathan's Evolution: The Curse represents Nathan's      │
    │ transition from reality-adjacent performance into scripted narrative while │
    │ maintaining his core questions about authenticity, exploitation, and       │
    │ identity.                                                                   │
    └─────────────────────────────────────────────────────────────────────────────┘

    ═══════════════════════════════════════════════════════════════════════════════
    ▶ THE REHEARSAL SEASON 2: Performance as Advocacy
    ═══════════════════════════════════════════════════════════════════════════════

    ▼ The Final Evolution: When Character Becomes Everything

    The Rehearsal Season 2 presents itself as Nathan's pivot toward airline
    safety advocacy. He's discovered a genuine problem: pilots don't effectively
    communicate in moments of crisis, with first officers often knowing something
    is wrong but failing to call out the captain. It's a real issue that costs
    lives.

    Nathan finds Robert Bent, a former NTSB investigator who spent years trying
    to convince the government that pilots needed roleplay training. Bent's
    frustration with bureaucratic inaction mirrors Nathan's own relationship with
    being heard and understood. Together, they create "Wings of Voice," a reality
    show testing pilot communication under pressure.

    The show becomes simultaneously hilarious and genuinely advocative. Nathan is
    surfacing real problems that pilots discuss constantly, using his platform
    for authentic social impact while maintaining his comedic framework. This
    appears to be Nathan's most socially conscious work yet.

    ────────────────────────────────────────────────────────────────────────────────

    Then comes the devastating finale reveal:

    ╔═════════════════════════════════════════════════════════════════════════════╗
    ║                           "TWO YEARS EARLIER."                             ║
    ╚═════════════════════════════════════════════════════════════════════════════╝

    This isn't just a timestamp; it's a narrative detonation. The reveal exposes
    that his entire advocacy narrative was not a spontaneous evolution but a
    meticulously constructed two-year project. Nathan hadn't just stumbled into
    activism; he had architected it, crafting not merely a show about
    communication but an elaborate meta-narrative of his own supposed
    transformation. Every displayed moment of genuine concern, every empathetic
    nod, was a calculated beat in a gripping story designed to showcase a
    profound personal shift—a performance of becoming.

    But the most telling moment is Nathan deleting a voicemail about his brain
    scan results without listening. This isn't anxiety - it's Nathan actively
    choosing to remain his constructed character rather than receive medical
    information that might help him understand his actual self. The voicemail
    represents AMNF's last chance, offering clinical insight into his
    neurodivergence that might provide genuine self-understanding.

    Nathan chooses CNF. He deletes the message to preserve the character he's
    become rather than risk learning who he actually is. CNF hasn't just consumed
    AMNF - Nathan is now actively participating in AMNF's erasure, choosing
    performance over diagnosis, constructed identity over authentic self-knowledge.

    ▼ The Insanity of What He Actually Did

    To fully grasp the scope of Nathan's commitment to performance over
    authenticity, consider what he actually constructed for Season 2. This wasn't
    just a television show - it was a series of nested realities so elaborate
    they border on the delusional.

    Nathan didn't just create segments about pilot communication - he produced an
    entire fake reality competition series called "Wings of Voice," complete with
    contestants who believed they were competing for a real prize,
    professional-grade challenges, and elimination ceremonies. Over a thousand
    real people applied and auditioned for what they thought was a legitimate
    aviation-themed reality show.

    Meanwhile, Nathan was simultaneously inhabiting Captain Sully Sullenberger's
    life story, not through casual research but by systematically recreating the
    formative experiences that shaped one of America's most celebrated heroes. He
    spent months learning to fly, training in Boeing 747 simulators with the same
    intensity that characterized Sully's career, attempting to understand heroism
    by living someone else's defining experiences.

    The layers of artifice are staggering: contestants were performing for
    Nathan's fake show while Nathan was performing Sully's real life while
    filming everything for his actual show, all while studying how performance
    affects authentic communication. Nathan became technically capable of the same
    heroic actions as Sully, but through a process so artificial that it raises
    fundamental questions about what heroism actually means.

    ┌─────────────────────────────────────────────────────────────────────────────┐
    │ Can courage exist when it's constructed? Is competence authentic when it's │
    │ performed?                                                                  │
    └─────────────────────────────────────────────────────────────────────────────┘

    ▼ The Real Ending: When CNF Consumes AMNF

    The season's conclusion reveals that Nathan's pilot safety advocacy was never
    really the point. The congressional testimony went nowhere - actual pilots on
    Reddit noted that Nathan didn't provide compelling enough arguments to change
    training protocols. The real story is Nathan's continued avoidance of
    accepting his neurodivergence and his unwillingness to exist as Actual Man
    Nathan Fielder (AMNF) rather than Character Nathan Fielder (CNF).

    ┌─ The Complete Dissolution ─────────────────────────────────────────────────┐
    │ By the end, CNF has taken over completely. AMNF is dissolving as a         │
    │ premise. Nathan can no longer access authentic experience without the      │
    │ elaborate constructions that CNF requires. The character has consumed the  │
    │ person so thoroughly that there may no longer be a meaningful distinction  │
    │ between them.                                                               │
    └─────────────────────────────────────────────────────────────────────────────┘

    ┌─ CNF as Survival Strategy ─────────────────────────────────────────────────┐
    │ Nathan has so little of AMNF left that he might be totally becoming CNF as │
    │ a means of coping with his own neurodivergence and inability to relate to  │
    │ common society. The elaborate constructions, the constant performance, the  │
    │ need for scripts and rehearsals - these aren't just comedy devices         │
    │ anymore. They're how Nathan navigates a world that feels fundamentally     │
    │ foreign to him.                                                             │
    │                                                                             │
    │ The Character as Crutch: CNF provides Nathan with a framework for social   │
    │ interaction that AMNF cannot manage. Through CNF, Nathan can approach      │
    │ people with predetermined scripts, clear objectives, and defined roles.    │
    │ The character becomes his interface with humanity - a translation layer    │
    │ between his authentic self and a world he struggles to understand          │
    │ intuitively.                                                                │
    │                                                                             │
    │ What started as performance has become Nathan's primary mode of existence. │
    │ CNF isn't just who Nathan plays on television - CNF is who Nathan has      │
    │ become in order to function in the world. AMNF may no longer exist as     │
    │ anything more than a memory of someone who once struggled to connect,      │
    │ before he found a character who could do it for him.                       │
    └─────────────────────────────────────────────────────────────────────────────┘

    ═══════════════════════════════════════════════════════════════════════════════
    ▶ PERSONAL REFLECTION: What It Means to Be a Person
    ═══════════════════════════════════════════════════════════════════════════════

    ▼ The Meta-Commentary

    It goes deeper. There is a meta commentary about what it even means to be a
    person here. And Nathan is deeply confused by that. I am too. I have spent my
    entire life trying to fit in, and have become quite good at it. But along the
    way it's been massive steps of growth trying to get myself out there and
    "rehearse" running through making friends and living life in over ten
    different cities in a decade. Nathan's deeply unsettled.

    What Nathan has created through his elaborate constructions is essentially a
    systematic approach to the same problem many of us face quietly: how do you
    learn to be human when the rules feel fundamentally foreign? His television
    shows become laboratories for social interaction, testing grounds for
    authentic connection, rehearsal spaces for the basic human experiences that
    others seem to navigate intuitively.

    The uncomfortable truth is that Nathan's methods - the obsessive preparation,
    the scripted interactions, the need to control every variable - might be more
    relatable than we want to admit. How many of us rehearse conversations in our
    heads? How many practice our responses, craft our personas, perform versions
    of ourselves that we think will be more acceptable? Nathan has simply taken
    this universal human experience and made it visible, systematic, and extreme.

    But there's something deeply unsettling about watching someone go to these
    lengths and still end up isolated, still struggling with the same fundamental
    questions about identity and belonging. It forces the question: if elaborate
    preparation and perfect execution can't solve the problem of human connection,
    what can? If Nathan, with all his resources and commitment, still can't figure
    out how to simply be himself with other people, what hope is there for the
    rest of us?

    The most disturbing possibility is that Nathan's journey represents not an
    aberration, but an acceleration - a glimpse into what happens when the
    performative aspects of social interaction become so consuming that they
    replace the authentic self entirely. In a world where we're all performing
    versions of ourselves on social media, where authentic interaction
    increasingly feels scripted, Nathan's complete transformation into CNF might
    be less of a psychological curiosity and more of a cautionary tale about where
    we're all heading.

    ▼ The Terrifying Implication

    Nathan has gone further than almost anyone in exploring these questions
    through performance, through elaborate constructions, through every possible
    angle of investigating authenticity and human connection.

    And he still feels like he's not fitting in with the rest of the world. He
    still doesn't know who he is.

    What is the takeaway if he can go this far and still feel disconnected? What
    does that mean for the rest of us who struggle with these same fundamental
    questions about connection, identity, and belonging?

    ▼ The Shared Experience

    Maybe that's why Nathan's work is so viscerally affecting. It's not just
    comedy or performance art or social commentary - it's someone publicly
    working through the same confusion about human connection that many of us feel
    privately. The elaborate constructions become a way of saying: "I don't
    understand how to be a person either, so let me try every possible approach
    and see if any of them work."

    And the fact that none of them fully work might be the most honest thing of
    all.

    ═══════════════════════════════════════════════════════════════════════════════
    ▶ COMPLETE TIMELINE: The Transformation of Nathan Fielder
    ═══════════════════════════════════════════════════════════════════════════════

    ┌─ 1983: Birth & Early Foundations ──────────────────────────────────────────┐
    │ Born May 12 to Eric and Deb Fielder, both social workers, in Vancouver's   │
    │ Dunbar neighbourhood. Jewish family, middle-class upbringing with younger  │
    │ sister Becca. From an early age, exhibited love for elaborate pranks and   │
    │ constructed stories to cope with feelings of inadequacy and shyness. These │
    │ early coping mechanisms would evolve into his life's work.                 │
    └─────────────────────────────────────────────────────────────────────────────┘

    ┌─ 1996-2001: Point Grey Secondary School ───────────────────────────────────┐
    │ Joins improv comedy group alongside future star Seth Rogen. Team places   │
    │ third in national competition. Begins working as magician at age 13,       │
    │ performing at children's parties and magic shops - a dedication to illusion│
    │ that continues (still member of The Magic Castle in LA). Photos from this  │
    │ era show the same awkward positioning and deadpan expression that would    │
    │ define CNF.                                                                 │
    └─────────────────────────────────────────────────────────────────────────────┘

    ┌─ 2001-2005: University of Victoria ────────────────────────────────────────┐
    │ Pursues Bachelor of Commerce degree, graduating with "really good grades." │
    │ This business education becomes the foundation for his satirical approach  │
    │ to capitalism and corporate culture. The tension between genuine business  │
    │ knowledge and social awkwardness creates the perfect storm for his future  │
    │ persona.                                                                    │
    └─────────────────────────────────────────────────────────────────────────────┘

    ┌─ 2005-2006: The Pivot to Comedy ───────────────────────────────────────────┐
    │ Briefly works as broker - a legitimate business career abandoned for       │
    │ comedy. Relocates to Toronto, enrolls in Humber College comedy program.    │
    │ Receives prestigious Tim Sims Encouragement Fund Award as Canada's most    │
    │ promising new comedy act. The business world's loss becomes comedy's       │
    │ strangest gain.                                                             │
    └─────────────────────────────────────────────────────────────────────────────┘

    ┌─ 2007: Canadian Idol Writing ──────────────────────────────────────────────┐
    │ First major writing job on Canadian Idol Season 5. Works as segment        │
    │ producer, conducts first-round auditions. Work catches attention of CBC    │
    │ executive producer Michael Donovan, setting stage for breakthrough.        │
    └─────────────────────────────────────────────────────────────────────────────┘

    ╔═════════════════════════════════════════════════════════════════════════════╗
    ║ 2008-2009: "Nathan on Your Side" - This Hour Has 22 Minutes               ║
    ║                                                                             ║
    ║ THE GENESIS OF CNF: Field correspondent segments parodying consumer        ║
    ║ affairs reporting. AMNF's genuine desire to help people collides with his  ║
    ║ social awkwardness, creating the template for everything that follows. The ║
    ║ segments go viral, establishing Nathan's deadpan delivery and uncomfortable ║
    ║ interview style.                                                            ║
    ╚═════════════════════════════════════════════════════════════════════════════╝

    ┌─ 2010: Important Things with Demetri Martin ──────────────────────────────┐
    │ Writer for 10 episodes, actor in 3. Behind-the-scenes work developing     │
    │ comedy writing skills while CNF gestates in the background. Nathan learns │
    │ to weaponize his natural awkwardness for comedic effect.                  │
    └─────────────────────────────────────────────────────────────────────────────┘

    ╔═════════════════════════════════════════════════════════════════════════════╗
    ║ 2013: Nathan for You Premieres                                             ║
    ║                                                                             ║
    ║ February 28: Comedy Central launches the show that blurs all lines.       ║
    ║ Co-created with Michael Koman, produced by Abso Lutely Productions.        ║
    ║ • "Yogurt Shop/Pizzeria" (S1E1): Poop-flavored frozen yogurt establishes  ║
    ║   commitment to absurdity                                                  ║
    ║ • "Haunted House/The Hunk" (S1E5): First fake reality show within the     ║
    ║   show - template for future nested realities                             ║
    ╚═════════════════════════════════════════════════════════════════════════════╝

    ╔═════════════════════════════════════════════════════════════════════════════╗
    ║ 2014: Reality Begins Breaking                                              ║
    ║                                                                             ║
    ║ THE YEAR NATHAN ESCAPES THE SHOW:                                         ║
    ║ • "Dumb Starbucks" (S2E5): Parody coffee shop becomes international news, ║
    ║   lines around block, CNN coverage                                         ║
    ║ • "Smokers Allowed" (S2E6): Legal loophole exploitation - bars become     ║
    ║   "theaters" to allow smoking                                              ║
    ║ • Wins Canadian Comedy Award for Best Performance by a Male               ║
    ║ • Named Just for Laughs Breakout Comedy Star of the Year                  ║
    ╚═════════════════════════════════════════════════════════════════════════════╝

    ╔═════════════════════════════════════════════════════════════════════════════╗
    ║ 2015: Peak Nathan for You Era                                              ║
    ║                                                                             ║
    ║ THE SCHEMES BECOME CULTURAL EVENTS:                                        ║
    ║ • "Electronics Store" (S3E1): $1 TV with alligator obstacle course vs     ║
    ║   Best Buy                                                                  ║
    ║ • "The Movement" (S3E3): Creates actual fitness trend, writes entire      ║
    ║   book, free labor as exercise                                             ║
    ║ • "The Hero" (S3E8): 7 months training to secretly walk tightrope as      ║
    ║   Corey Calderwood                                                         ║
    ║ • Summit Ice Apparel: Real Holocaust education company, nearly $500K in   ║
    ║   sales                                                                     ║
    ╚═════════════════════════════════════════════════════════════════════════════╝

    ╔═════════════════════════════════════════════════════════════════════════════╗
    ║ 2017: The End and The Beginning                                            ║
    ║                                                                             ║
    ║ NATHAN FOR YOU'S FINAL SEASON:                                            ║
    ║ • "The Richards Tip" (S4E1): Months of taxi driver training for single    ║
    ║   fare                                                                      ║
    ║ • "The Anecdote" (S4E4): Manufacturing reality to tell on Jimmy Kimmel -  ║
    ║   CNF plays AMNF playing himself                                           ║
    ║ • "Finding Frances" (S4E8): 84-minute finale, praised by Errol Morris as  ║
    ║   "unfathomably great"                                                     ║
    ║ • Series ends November 9 - Nathan disappears from public view             ║
    ╚═════════════════════════════════════════════════════════════════════════════╝

    ╔═════════════════════════════════════════════════════════════════════════════╗
    ║ 2017-2022: The Five-Year Disappearance                                    ║
    ║                                                                             ║
    ║ THE VOID: Nathan largely vanishes from public performance. Questions about ║
    ║ identity go dormant. Behind the scenes:                                    ║
    ║ • 2018: Consulting producer on Sacha Baron Cohen's "Who Is America?"      ║
    ║ • 2019: Writers Guild Award for Nathan For You                            ║
    ║ • 2020-2023: Executive Producer "How To with John Wilson" (HBO)           ║
    ║ • Appears in bread scene on Wilson's show - which Nathan is this?         ║
    ╚═════════════════════════════════════════════════════════════════════════════╝

    ╔═════════════════════════════════════════════════════════════════════════════╗
    ║ 2022: The Rehearsal Season 1                                              ║
    ║                                                                             ║
    ║ July 15: THE RETURN ON HBO - Unlimited budget, complete creative freedom  ║
    ║ • Laser-scanned apartment replicas, conversation flowcharts               ║
    ║ • Trivia confession rehearsal spirals into existential crisis             ║
    ║ • COVID forces pivot to parenting - child actors rotate through           ║
    ║ • Nathan transports Oregon replica house - constructed reality becomes    ║
    ║   home                                                                     ║
    ║ • CNF begins consuming AMNF completely                                     ║
    ╚═════════════════════════════════════════════════════════════════════════════╝

    ╔═════════════════════════════════════════════════════════════════════════════╗
    ║ 2023: The Curse                                                           ║
    ║                                                                             ║
    ║ November: SCRIPTED TELEVISION DEBUT                                        ║
    ║ • Co-created with Benny Safdie, stars with Emma Stone                     ║
    ║ • Plays Asher Siegel in show-within-show "Fliplanthropy"                  ║
    ║ • Explores gentrification, white guilt, reality TV artifice               ║
    ║ • Christopher Nolan praises as show with "no precedents"                  ║
    ║ • 94% Rotten Tomatoes, widespread critical acclaim                         ║
    ╚═════════════════════════════════════════════════════════════════════════════╝

    ╔═════════════════════════════════════════════════════════════════════════════╗
    ║ 2024: The Rehearsal Season 2                                              ║
    ║                                                                             ║
    ║ April 20: THE COMPLETE TRANSFORMATION                                      ║
    ║ • "Wings of Voice" - fake reality show with 1,000+ real contestants       ║
    ║ • Months learning to fly Boeing 747 simulator as Sully Sullenberger       ║
    ║ • Staged congressional testimony on aviation safety                        ║
    ║ • CRUCIAL: Deletes brain scan voicemail without listening - choosing CNF  ║
    ║   over diagnosis                                                           ║
    ║ • Reveal: "TWO YEARS EARLIER" - entire season was performance of          ║
    ║   transformation                                                           ║
    ╚═════════════════════════════════════════════════════════════════════════════╝

    ╔═════════════════════════════════════════════════════════════════════════════╗
    ║ 2025: Present Day - CNF Complete                                          ║
    ║                                                                             ║
    ║ Nathan exists primarily as CNF. The character has become his method of     ║
    ║ navigating the world. Press appearances maintain persona without break. No ║
    ║ distinction between performance and existence. The elaborate constructions ║
    ║ are now his primary reality. AMNF may no longer exist as anything more    ║
    ║ than a memory - a person who once needed to cope before the coping        ║
    ║ mechanism became complete.                                                 ║
    ╚═════════════════════════════════════════════════════════════════════════════╝

    ▼ The Pattern of Dissolution

    What this timeline reveals is not just a career progression but a systematic
    dissolution of identity. Each project pushes further into the space between
    performance and reality until that space no longer exists. The early Nathan
    who did magic at children's parties and worked as a broker has been
    completely subsumed by the Nathan who appears on our screens.

    The trajectory shows:
    • 2008-2012: Learning to weaponize natural awkwardness
    • 2013-2015: Developing elaborate schemes that blur help and exploitation
    • 2016-2017: Creating realities that escape into actual culture
    • 2017-2022: Disappearing to process or avoid the implications
    • 2022-2024: Using performance to explore identity directly
    • 2025: Complete transformation where performance is identity

    The most telling moment may be deleting the brain scan results - actively
    choosing to remain CNF rather than understand AMNF. This isn't just method
    acting or commitment to a bit. It's the complete replacement of one identity
    system with another, more functional one. Nathan has solved the problem of
    being Nathan by becoming "Nathan" permanently.

    ################################################################################
    #                               END DOCUMENT                                   #
    ################################################################################
    """
  end
end
