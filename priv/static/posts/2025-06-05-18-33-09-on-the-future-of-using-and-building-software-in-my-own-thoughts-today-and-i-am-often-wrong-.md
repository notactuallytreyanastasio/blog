tags: software,ai,programming,prediction,reflection

# On The Future of Using and Building Software (in my own thoughts, today, and I am often wrong)
I have been thinking a lot about software lately, and how the advent of AI lately has really changed everything.
I wanted to gather some thoughts on that here and share them with anyone who might be inclined to read them, and is also thinking about the future.
I am not a doomer and I am simply trying to work through some thoughts about building software, people and how they use it, and what I see as fundamental changes in how we might approach work and how we think about it as a whole as engineers in the near future.

I am going to start by outlining some thoughts on what I believe will be a large evolving market class that will fuel a lot of innovation and also be a burgeoning sector to build products in.

## People's Interaction With Computers
I think the way we fundamentally interact with computers is changing, and I think that right now the means of how that is going to propogate is exclusively centered around developers.
Right now, with the advent of the tools Open AI, Anthropic, etc have launched, we fundamentally are changing how we approach work itself.
This has some terrible short sighted consequences that are the result of people making ill informed decisions.
That said, while Chat GPT and the likes are replacing things they shouldn't be (in my opinion, both ethically and long term as a growth model for a business), I think there is going to be a massive change in _how we do our jobs_ because of the tooling that it offers.

Right now, people just see a simple chat interface when they go to interact with an AI, for the most part.
This is fundamentally different than the way people have interacted with computers for decades.

### Inverted Computers: Language-Based UI vs Fundamental Logic
The post [LLMs Are Weird Computers](https://www.phillipcarter.dev/posts/llms-computers) really hit a lot of notes that I found to resonate with me.
The idea here is that we have fundamentally changed what our idea of a computer is, if we view the LLM as a black box that performs work.
It is a completely new interface to the machine that we used to have to operate in a way so manual that the interface to speak to it was a programming language in a shell with no graphical user interface whatsoever.

With this, there comes a fundamental change in intent.

Let's take a look at one of their examples.

> An inverted computer

> If traditional computers are precision machines that struggle with fuzziness, LLMs are the inverse: fuzzy machines that struggle with precision (unless calling out to a traditional computer to do a precision task).

> Imagine two tasks:

> Successively multiplying larger and larger numbers together

> Calculating the understanding of a phrase

Now, we might run some python code for the first one.

```
python run mul.py
12324842551279 (calculated instantly and perfectly)
```

or

```
python run understanding.py
The understanding of the phrase "Explain what makes the sunset beautiful?" is:
"TODO implement something, idk, this is impossible without machine learning"
```

or, me re-asking the question to an LLM right now just to see:

> 429052095942052 * 4250945290452

> Thought process

> The user is asking me to multiply two large numbers:
> 429052095942052 * 4250945290452

> Let me check if this requires the analysis tool. According to the guidelines, calculations with 6+ digit numbers necessitate using the analysis tool. The first number has 15 digits and the second has 13 digits, so this definitely requires the analysis tool.

> I'll calculate this multiplication for you using the analysis tool.

> The calculation has been completed. The result is approximately 1.82 × 10^27, or more precisely: 1,823,876,986,603,425,500,000,000,000.

> The result of 429052095942052 × 4250945290452 is:

> 1,823,876,986,603,425,500,000,000,000

> That's approximately 1.82 × 10²⁷ (or about 1.82 octillion).

Now, this time Claude 4 Opus knew to use a trick.

But a month ago (today is 6/5/2025) this was not true!

LLM's, as a whole, really, are _not_ great at math.
They predict tokens!
That isn't an inherently totally logical activity.

- **Intent replaces navigation**: "Show me sales data from Q3" vs opening Excel → navigating to folder → opening file → filtering data
- **Conversational flow replaces rigid workflows**: Each interaction builds on context rather than starting fresh
- **Ambiguity becomes acceptable**: The system interprets unclear requests rather than throwing errors
- **Discovery happens through dialogue**: You learn capabilities by asking, not by exploring menus

This inversion fundamentally changes the cognitive load of computing from procedural knowledge (how to do things) to declarative knowledge (what you want).

### Evolution of Interfaces: Visual Programming and End User Programming (EUP)

We're witnessing the culmination of decades of interface evolution that has consistently moved toward democratizing computing power:

**Historical progression:**
- **Command lines** → **GUIs** → **Touch interfaces** → **Voice** → **Natural language AI**
- Each step reduced the technical knowledge barrier

**Visual programming emergence:**
- Tools like Scratch, Node-RED, and Zapier already let non-programmers create logic through visual metaphors
- No-code/low-code platforms (Webflow, Airtable, Notion databases) give end users programming-like capabilities
- These tools succeed because they map computational concepts to familiar visual metaphors

**End User Programming revolution:**
- EUP has always existed (Excel formulas, email rules, browser bookmarks) but was limited
- AI interfaces are the ultimate EUP tool - natural language becomes the programming syntax
- Users can now create complex automations, data transformations, and custom workflows without understanding underlying systems
- The barrier between "user" and "programmer" dissolves when everyone can describe what they want in plain language

**Convergence point:** We're approaching interfaces that combine the power of programming with the accessibility of conversation, making every user a potential power user.

### MCP as the Underlying Revolution

Model Context Protocol (MCP) represents the plumbing that makes language-based computing possible at scale. It's the foundational layer that enables the interface revolution:

**What MCP enables:**
- **Standardized tool connectivity**: AI systems can reliably connect to any system with an MCP server
- **Context preservation**: Tools can share rich context rather than operating in isolation
- **Composable functionality**: Complex workflows emerge from combining simple, well-defined tools
- **Decentralized capability expansion**: Anyone can create MCP servers to expose new capabilities

**The hidden revolution:**
- MCP is to AI interfaces what HTTP was to the web - invisible infrastructure that enables everything
- It solves the "last mile" problem of connecting language models to actual systems
- Creates a marketplace of capabilities where tools compete on functionality, not integration complexity
- Enables the "inverted computer" by providing reliable bridges between natural language intent and system actions

**Why it's revolutionary:**
- **Eliminates integration tax**: No more custom APIs for every tool combination
- **Enables emergent workflows**: Users discover new capabilities by combining existing tools in conversation
- **Creates network effects**: Each new MCP server increases the value of the entire ecosystem
- **Future-proofs AI development**: Tools built today work with AI systems built tomorrow

MCP is the technical foundation that makes conversational computing practical rather than just possible.

### MCP's Evolution: From Developer-Centric to Consumer-Facing

Currently, MCP exists primarily in developer contexts - CLI tools, development environments, and technical workflows. But the real transformation happens when this capability reaches consumers:

**Current state (developer-centric):**
- MCP servers for development tools (GitHub, databases, cloud services)
- Technical users creating custom integrations
- Focus on productivity tools for knowledge workers
- Requires understanding of underlying systems

**The consumer transition:**
- **Abstraction layers**: Consumer apps will hide MCP complexity behind simple interfaces
- **Pre-built server ecosystems**: App stores of MCP servers for common consumer needs
- **Visual MCP builders**: Drag-and-drop tools to create custom integrations without coding
- **Embedded AI agents**: Every app becomes conversational, powered by MCP connections

**Consumer-facing implications:**
- **Personal automation revolution**: Everyone gets IFTTT-level automation through conversation
- **Data sovereignty**: Users can connect their own tools rather than being locked into platforms
- **Emergent use cases**: Consumers will discover workflow combinations that developers never imagined
- **New business models**: Services compete on MCP server quality, not platform lock-in

**The tipping point:**
When grandmother can say "Connect my photo app to my calendar so family pictures automatically create event reminders" and it just works, MCP has achieved its consumer potential. This shift transforms every software interaction from a series of separate app experiences into a unified, conversational computing environment.

The real future isn't AI replacing human work - it's AI making every human a power user of the entire digital ecosystem.


