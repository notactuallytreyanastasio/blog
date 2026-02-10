tags: programming,elixir,machine-learning,apple-silicon,deep-dive,wat

# Many Layer Dips: I Decided to Try Making A Robot (LLM) Post Like Me

## I Think This Is Bad, Actually

I don't think its good to have an LLM pretend to be a person.

I don't think its good to have LLMs generate pictures.

I don't think its good to have children chatting with LLMs.

I don't think its a good idea in general to be betting on them for anything but being programming power tools.

This is a demonstration of me using a power tool.
I am using the power tool as a bit.
I am not recommending anyone actually do this.

It is all for the laughs.

That said, some interesting and real technical content came from doing all this.

I wanted to contribute back so I took it all the way.

Anyways, here we go.
This is a deeply technical post and as of starting this paragraph my guess is 6000-7000 words.

Let's see how I do.

Hopefully this is at least entertaining, maybe educational.

At the time of writing I am guessing we will break 5,000 words.

## Premises

For 13 years I posted like 60 times a day.
I post through it like no other, reader.
This gave me a pile of 250,000 posts.

Obviously, some of this is retweets, some of its replies treating the site like a group text, etc.
There was a lot going on there.

And there still Bluesky.
I have another 25,000 there.

The Python code honestly ended up pretty simple for calling it all:

```python
model, tokenizer = load(
    "lmstudio-community/Qwen3-8B-MLX-4bit",
    adapter_path="adapters/v5"
)

response = generate(
    model, tokenizer,
    prompt="Write a post in your authentic voice.",
    max_tokens=280
)
```

I mean, this was fine.

But I prefer to write things in Elixir.
