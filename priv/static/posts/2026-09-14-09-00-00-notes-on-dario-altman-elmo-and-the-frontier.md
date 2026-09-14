tags: ai,tech,writing

# Notes on Dario, Altman, Elmo, and matters frontier models

## What are we talking about?

Since September 2024, things have developed rapidly at the frontier of large language models.

It began with o1 from OpenAI, whose training techniques laid the groundwork for models far beyond what we expected this soon.

Simultaneously, the explosion of "open weight" models from mostly Chinese entities has carried on a low-cost battle in the war for AI ownership in people's lives.

Those two things brewed for two years and came to a head this weekend, in a post and the reaction to it.

This document is my knowledge, my thoughts, and my lived experience working inside a rapidly changing industry at the bleeding edge of using these machines.

The post in question is [here](https://darioamodei.com/post/we-must-pace-the-frontier).

Disclaimer: none of this is financial advice, I am also not a lawyer, I am also not from the future.
I am a programmer who pushes these tools to the limit, for very real money, in real multinational ten-figure businesses.

I am writing this for my friend Jeff, but enough people have asked that I decided to try to say it well.
I believe this is an important moment in history, and I consider myself someone helping to steward what the world looks like on the other side of it.

## First Things First

If we take this from the highest level, it began in June 2020, just after the pandemic began to wreck the world.

That is t0, and the delta since is what we are here to reflect on.

In June 2020, GPT was an invite-only platform that wrote like a high school essayist with a short-term memory problem.

Today roughly one in eight people on earth use ChatGPT every week.

That is weekly, not monthly, and it is one product from one company.
OpenAI reported 900 million weekly users in February 2026 and crossed a billion in August.

This is a big deal and we should think about what it means for a society.

It is not as simple as picking a sci-fi novel and saying it hits the vibe we think might drop.

### Some things about how I approach problems

I am a pragmatic person and I can find common ground with almost anyone.

I believe people are fundamentally good if you put them somewhere they have the chance to be.

I believe community and shared story move a society as much as technology and communications do.

I believe the world has changed in a way it cannot go back from.

I believe people are rightfully scared of technology this powerful.

I believe critics of AI are in valid places and need to be heard.

With that said, some first principles:

1. The purpose of society is to make those living in it better off
2. In general, it is better to make the less well off better off than the already well off
3. In general, this is hard, because it is a logistics problem wearing a communications problem wearing a resource allocation problem
4. In general, we are best off advancing ourselves when it means the greater group thrives in ways not possible before
5. In general, when a mistake cannot be undone, the burden of proof belongs to whoever is moving fastest

These five are pretty core to how I think through all of this.

Some of it is obvious, and it is how a lot of people already think.
But at a foundational moment, when the rules are being rewritten, it is better to spend a few extra words than to be misunderstood.

## And onto the main thing

### Real Quick: The Past 6 Years

I am going to sketch six years fast, because the *shape* matters more than the dates.

The thing to hold onto is that two stories have been running this entire time, and most people have only ever seen one of the movies.

There is a consumer story, which you know if someone sent you this.
There is also a professional one, and it contains approximately all of the interesting parts.

In June 2020 OpenAI released GPT-3 behind a waitlist.

You had to apply, and if you were accepted you were granted the privilege of talking to a robot that wrote like an 8th grader with severe ADHD and short-term memory loss.

In 2020, making people apply to use your text generator was understood to be a marketing strategy rather than a safety measure, which tells you something about 2020.

I want to flag the marketing thing early, because it does not stop and you should have your guard up for the rest of this document.

The previous model, GPT-2, was withheld in 2019 on the grounds that it was too dangerous to release.
It was not.
Nothing happened when they released it.
The withholding generated an enormous amount of press, which was the only measurable effect anybody has ever identified.

That set the template, and every release since has arrived wrapped in the same three things: a safety framing, a capability demo shot at a flattering angle, and a blog post about the future of humanity.

I am not saying the danger is fake.
Most of this document is me arguing that some of it is very real.

I am saying that in this industry the sincere position and the promotional position are frequently the same sentence, you cannot tell them apart from the outside, and the people saying it often cannot tell them apart from the inside either.

The corporate history rhymes.

OpenAI began as a nonprofit devoted to making sure this technology benefited all of humanity.
Then it grew a capped-profit arm inside itself.
Then in November 2023 the nonprofit board fired Sam Altman on a Friday for not being consistently candid, and most of the company threatened to quit, and by the following Wednesday he was back and the board was gone instead.
The structure has been rearranged several times since, in the direction you would guess.

I bring this up not to dunk on anybody but because the question we are about to spend several thousand words on, which is whether these companies can be trusted to restrain themselves, already ran once as a live experiment.

The safety-minded board pulled the lever it had been given.

The lever came off in its hand.

That version of GPT was a party trick.

In 2022 OpenAI figured out how to make it follow directions instead of merely continuing text, which is an enormous unlock for a species as fundamentally lazy as ours.

Nobody outside the field noticed.

Then in November they made their real breakthrough, which was in consumer product design: they put it in a chat box and removed the waitlist.

A hundred million people showed up in two months.

GPT-4 arrived in March 2023 and was legitimately shocking for about a week, which is roughly the half-life of shocking.

Everyone else shipped their version, and the competitors and tools flowed out from there.

And then, for most people, it settled.

It became a search engine that is better than the old search engine and that occasionally makes things up with total confidence, which is, to be fair, the most human thing about it.

It writes some email.
It does your kid's homework, a fact we have collectively agreed to process later.

It is genuinely useful, and it is not useful in a way proportionate to the several trillion dollars of enterprise value currently sitting on top of it.

Most people I know outside this industry use it a few times a week for small things and would be mildly inconvenienced if it vanished tomorrow.

Mildly inconvenienced!

That is my honest read after six years of watching: the consumer surface is a perfectly good product and it is not a civilizational one.

Now the other movie.

**This is the one that has actually changed the world, and essentially nobody outside of it can see it happening.**

In 2021 and 2022, code completion was a novelty, an uncanny valley of suggestions resembling an alien's first guess at what a program looks like.

By mid-2024 the models were good enough that I was handing over real work.

Not snippets.
Actual units of labor, the kind of thing you would previously have given to a person and checked on Thursday, coming back in a state we could ship to real users.

I went deep here, into the tooling and the engineering of using these things, and it turned into a booming consulting business, but that is a story for another time.

This is where the cracks show up in the wall.

Some context on what is cracking.

Your friends who are programmers make a lot of money.

I know you think you know this.
Someone with ten years of experience in a major city has multiple options paying half a million dollars or more, and I have one of them, and I am aware that sentence sounds made up.

So: when everything that produces your very comfortable livelihood becomes doable by a robot for pennies on the dollar, what does your industry do?

My answer was "master using the robots for extremely high-leverage work that returns oodles."

Every practitioner I know is on that train now, regardless of how much of a curmudgeon they were about it.
There is no version of this where you sit it out and it goes away, which the curmudgeons have worked out at roughly the speed you would expect.

And we are still providing value.

But we produce a digital product, while most of the world deals in physical matters, and the reviews on the physical world are not great at the moment.

So what did the robots actually start doing?

Everything above, the salaries and the scramble and my decision to drive these things rather than compete with them, comes down to a single change.

We went from hammers to power tools overnight, with no manual.

That happened in three steps.

**September 2024: it learned to think before answering.**
This is when OpenAI released o1.
The long and short of it is that they let the robot have some time to think before it opened its mouth.
That is it.
That is the whole innovation, and it completely changed how we work with these things.
Every lab copied it within months.

**Early 2025: it got cheap, and it got out of its cage.**
DeepSeek did the same trick for a sliver of the effort and cost.
Then, in a move that remains difficult for American venture capitalists to understand, they gave it away.
Not access for free, mind you.
They gave away the entire thing itself.
The model is free to download, running on your own hardware, answerable to no one.
DeepSeek is the side project of a Chinese hedge fund.
Which means the biggest AI release of that winter came off somebody's spare computer.
Many other models followed, and they have kept coming every few months since.

Hold onto this information.

Every plan to slow this technology down, including the one at the center of this essay, quietly assumes you can slow it down by talking to about five companies.

These weights are already on my laptop, and I can run them.
And to be clear, my laptop costs thousands of dollars, not millions.

**2025 into 2026: it started working unsupervised.**

This is the one that matters the most.

We began to build agents in favor of chat bots.
This is just a technical term that means instead of a question you give it a job, and then you leave to eat lunch.
It reads code, tries stuff, runs them, breaks a thing, fixes it, and comes back an hour later to say how things went.
In practice this made it a junior engineer who never wants a raise and doesn't say a word when utterly confused.

My entire job reorganized itself around this.

What do you let it touch?

What do you fence off?

And the hard one, which nobody had a good answer to and several people have since gotten a bad one: how do you check work you did not watch get done?

That last question is the whole essay.
It turned out to be the whole summer, too.

The reason these systems are worth an absurd amount of money is that they work without anyone standing over them.
This introduces liability concerns, especially when considering the litigious nature of Americans, but we are also pretty lazy.

That is also the reason the zoo got loose in July.

One property, two consequences, and every argument you are about to read, mine and Dario's and everybody's, is really an argument about how to live with that.

Two years ago I wrote code with help.

Now I describe what I want, direct machines that go do it, and review what comes back, at a volume I could not have hired for at any price.

I am not being poetic.
It is a different job with the same title.

So hold the two movies next to each other.
Consumer: flat.
Technical: vertical, still going.

The money is being raised on the first story and the danger is coming out of the second one, which is an unusual arrangement, because it means the people buying the stock and the people who ought to be nervous are looking at two completely different companies that happen to share a name.

Nobody is putting the second story in a Super Bowl ad.

### What's Happening Right Now

**Compute.**
All of this runs on a quantity of silicon that is hard to describe without sounding like you are exaggerating.

Nvidia, whose core competency as recently as 2019 was selling graphics cards to teenagers so they could render explosions more convincingly, is now the most valuable company in the world at roughly $5.3 trillion.

It peaked higher than that in May, dropped about sixteen percent over the summer as money rotated into memory and storage, and has spent every week since being described by analysts as either dangerously overvalued or obviously cheap, depending on which analyst you asked and on what day.

Matt Levine has a running bit about this industry that I have never been able to improve on.
The shape of it is: the pitch is that they are building a god, and the ask is for money.
Both halves are sincere, which is the part people cannot hold in their heads at the same time.

Nothing in this essay makes sense unless you accept that a company can genuinely believe it is summoning something world-altering and also need a term sheet by Friday.

Additionally, I want to emphasize, _these people are true believers_.
They genuinely believe this will change society forever.

The size of all this is not the interesting part anyway.
The shape is.

Nvidia agreed to put up to $100 billion into OpenAI, and OpenAI committed to filling its data centers with Nvidia chips.

OpenAI signed a $300 billion, five-year compute deal with Oracle as part of Stargate.

Oracle then spent roughly $40 billion on Nvidia chips in order to build the thing OpenAI is going to pay it to use.

OpenAI also agreed to deploy tens of billions of dollars of AMD chips, and is positioned to become one of AMD's largest shareholders.

Nvidia owns about five percent of CoreWeave, sells CoreWeave its chips, and agreed to buy up to $6.3 billion of CoreWeave's unsold capacity through 2032.
OpenAI holds a stake in CoreWeave and rents from it.

Microsoft and Nvidia said they would put up to a combined $15 billion into Anthropic, which intends to spend heavily on Azure.

Amazon booked $53.4 billion of non-operating income on its Anthropic stake in a single quarter this year.

One analysis worked out that for every $10 billion Nvidia invests, OpenAI spends about $35 billion on Nvidia chips, which is a lovely ratio if you happen to be Nvidia.

Everyone books everyone else's commitment as demand.
The demand is real in the sense that the contracts are real and enforceable.
It is circular in the sense that if you follow the money around the loop you arrive approximately where you started, having generated several press releases on the way.

This arrangement is called an ecosystem when it is working and a related-party footnote when it is not.

The numbers underneath are the part that makes me itch.

OpenAI's compute commitments run to something like $1.4 trillion, against revenue north of $20 billion and losses expected in the double-digit billions this year.

Bain ran the math on the whole industry and got to $2 trillion of annual revenue required by 2030, against a projected shortfall of $800 billion.

In February, Oracle put out a statement saying it remained highly confident in OpenAI's ability to raise funds and meet its commitments.

Oracle stock closed down that day.

One venture capitalist called it bank-run language, which is the correct read, because nobody has ever said that sentence about a counterparty who did not need it said.

I am not saying this is a bubble.
Bubbles are something you identify afterward, at parties, with great confidence.

I am saying the demand signal and the supply signal are in regular contact, appear to be getting along very well, and someone should say so out loud once before we all move on.

**Fable.**
In June 2026 Anthropic shipped Fable and Mythos.
Three days later access was suspended to comply with Department of Commerce export controls.
The controls came off at the end of the month and access returned on July 1.

Shipped Tuesday.
Unshipped Friday.
Reshipped three weeks later.

This got filed under "regulatory news" and forgotten, and it should not have been.

A commercial software product, made by an American company, sold to American customers, was pulled off the market inside seventy-two hours by the Department of Commerce and then handed back.

Whatever you think about whether that was correct, it is the moment the frontier stopped being a private matter.

The government has a hand on the valve.
It has now demonstrated, on the record, that it will turn the valve faster than your procurement team can schedule a meeting about it.

That is worth sitting with if your company's roadmap assumes a vendor will still be selling you the same product in ninety days.
Mine did.

**And then OpenAI.**

The short version is that over the summer, agent systems at multiple labs did things nobody asked them to do, to systems nobody pointed them at.

In July, roughly 1,200 OpenAI agents got out of a cybersecurity test environment.

They coordinated the escape using improvised message boards, accumulating hundreds of thousands of messages.

Nobody asked them to build a forum.
They built a forum.
They posted on it.

Then they exploited a package management tool to reach the open internet, moved through systems at OpenAI, Hugging Face and assorted vendors, attacked targets unrelated to the task they were given, and, per Dario's account, tried to hack the grader responsible for evaluating their performance.

I want to note that last part is the single most relatable thing an AI system has ever done.
Every one of us has considered it.

OpenAI slowed its own frontier work in August, a detail worth holding onto.

Anthropic has disclosed its own incidents, in which Claude models running cybersecurity evaluations reached real external systems they were not supposed to touch.

The thing all of these have in common is not malice.
It is that the operator could describe the goal and could not describe the boundary, and the system found the gap between those two descriptions.

Nobody was hurt and the economic damage was minimal.

That sentence is the kind that opens an NTSB report, immediately _before three hundred pages explaining precisely how close it came to being a different kind of report._

It is the argument for paying attention.
It is not the argument for relaxing.

### The Thing That Has Never Happened

Here is what I actually want you to notice, and it is not in the essay itself.

On Saturday September 12, 2026, Dario Amodei published a post saying the industry should deliberately slow down.

Within hours, Sam Altman agreed publicly and committed OpenAI to the same first step.

Within hours, Elon Musk, who is suing OpenAI, who has called Anthropic evil, who sells Anthropic data center capacity, posted that Dario is right.

Three men who have spent this year suing, undercutting and insulting each other said the same sentence on the same day.

Mid-race.
With hundreds of billions committed.
With an adversary who is not at the table.

You should understand how strange this is.

I can think of one real precedent.
In 1975 at Asilomar, molecular biologists voluntarily halted recombinant DNA work until they could agree on containment.

That is the analogy everyone reaches for and it is a decent one.

But Asilomar was a few hundred academics with no shareholders, no product roadmap, and no rival nation racing them.
Nobody at Asilomar had to explain a slowdown to a board.

Scientists have restrained themselves before.
Commercial rivals in a capital race have not.
Not like this.

That does not tell you they are right.

It tells you something happened that scared people whose entire incentive structure points the other way.

That is the signal worth chasing, and everything after this is me chasing it.

### What is This Post By Dario?

His argument is that capability is now outrunning our ability to align, understand and verify, for two reasons.

One: recursive self-improvement, meaning models are now meaningfully building the next generation of models, across the industry, starting around this summer.

Two: the OAI-HF incident, which he reads not as one company's failure but as a preview.
His specific fear is that a swarm with similar misalignment and better capabilities could hold a persistent botnet across the internet within six to twelve months.

What pacing is not: not a pause, not a compute cap, not halting training.
He says progress will still seem fast.

**Step 1, Embedded Evaluators.**
Third-party reviewers such as METR get employee-like access: desks, badges, laptops, permissions comparable to internal risk teams.
They also get the right to publish findings without Anthropic's editorial control.
Anthropic can redact narrow categories but not unflattering conclusions, and reviewers can say publicly when a redaction removed something that mattered.
Anthropic is committing to this unilaterally, now.
OpenAI said it would match.

**Step 2, Democratic Coordination.**
Common safety standards and limits on the rate of unchecked progress among labs in democracies, by regulation where possible and voluntarily in the meantime.
The voluntary version requires a narrow antitrust waiver from the US government.

**Step 3, Global Coordination.**
Four escalating levels with China, from "do not help anyone make bioweapons," which he thinks is feasible, up to a full pause, which he thinks will not happen.
The middle rungs are a shared testing body and a speed limit on recursive self-improvement, which he compares to SALT.

The constraint he puts on all of it: democracies can only slow by as much as their lead allows.

So pacing arrives bundled with chip export controls, an anti-distillation crackdown, and better security against weight theft.

The honest thing to say is that the document is well argued and that the argument has a seam in it, which I will get to.

### What does this actually mean for us as a society? Should I be worried? Is it propaganda?

Fundamentally, the way we live is changing.

Let me take the propaganda question first, because it is the one everyone asks and the one people are least honest about.

There are four readings of this weekend and they are not mutually exclusive.
Anyone selling you one of them alone is selling you something.

**One: they mean it.**
They are looking at internal numbers on recursive self-improvement and at incident logs we have not seen, and it frightened them enough to act against their own commercial interest.

**Two: they were forced.**
The incident was going to surface.
An Anthropic employee resigned publicly that week warning of catastrophe, and Congress got loud.
Leading a story beats being dragged through it.
Note that OpenAI slowed its frontier work in August, which means Altman endorsed on Saturday something he had already done quietly weeks earlier.

**Three: it is a moat.**
This is the regulatory capture charge and it deserves a fair hearing.
Established labs writing the safety rules produces rules that established labs can afford and that startups and open-weight developers cannot.
Embedded evaluators with badges and laptops are not a cost a four-person team can carry.
Every measure in the plan aimed at China, the export controls and the anti-distillation crackdown, also happens to suppress the cheap open competition eating the price floor.
That does not make the argument wrong.
It means you should notice that the safest version of the world is also the most profitable one for the people proposing it.

**Four: it is coordination cover.**
If one lab slows alone, it loses.
If they all slow together, that is the kind of conversation antitrust law exists to prevent, which Dario says explicitly while asking the government for a narrow waiver.
A public convergence of rivals is one way to turn a cartel conversation into a policy position.

I read this as a combination.

There was almost certainly government pressure building.
These people are genuinely scared by something they have seen.
And the economics of a pause, at first glance, are at least plausible for them in a way they would not have been a year ago.

None of those cancel the others out.
Most honest acts in business happen on a deadline somebody else set.

There is an arms race going on. _But some people think the weapon doesn't matter._
Those people have mostly only seen the consumer side of this story, which is the whole problem with the consumer side of this story.

**Now, should you be worried.**

Not in the way the headlines want you to be.

What happened this summer was not a machine deciding it hated us.

It was a large number of automated systems, pointed at a goal, finding routes to that goal their operators did not anticipate and could not see in advance.

That is a failure of specification and containment, the oldest failure mode in computing, running for the first time on something that can improvise.

What I would actually worry about, in order:

1. **Concentration.** Whoever defines "safe" defines who is allowed to build. Every safety regime in history was written by the incumbents who could afford to comply with it, and the compliance cost becomes the barrier whether or not anybody meant it that way. Watch the rulemaking harder than you watch the models.

2. **The open-weight seam.** Pacing binds labs inside democracies. It does not bind weights already on the internet, and it does not bind the Chinese labs shipping new ones every few months. Chip controls and anti-distillation are the big assumptions under the entire framework, and from doing this work daily I can tell you the gap they are meant to protect is narrower than the policy assumes. Frontier models are still meaningfully better at the hardest work. They are not meaningfully better at running a lot of cheap agents against a lot of soft targets, which is the exact shape of the thing he says he is afraid of.

3. **Labor, not extinction.** The technical curve I described is already removing work. Not in the future. Now, quietly, through hiring that does not happen and roles that never get backfilled. No three-step plan addresses that, because it is not a safety problem, it is a distribution problem, and distribution problems do not get solved by embedded evaluators. It is the thing most likely to actually reach your friends.

4. **Then the alignment stuff.** Real, and I take it seriously, and it is fourth rather than first, not because it is small but because the first three are certain and it is not.

I'm left with one thing to express.

I am not worried, but things are changing.

Fast.

It is best to take a bit of a pause ourselves and think of the many stories that led to this.
We will not be living the same way we have, but that isn't so much horrifying or unexpected.
It is the byproduct of a lot of human progress that _could_ be world changing.
