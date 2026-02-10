tags: programming,elixir,machine-learning,apple-silicon,deep-dive,wat

# Many Layer Dips: I Decided to Try Making A Robot (LLM) Post Like Me

## I Think This Is Bad, Actually

Before we get into the 12,000 words of technical content, I want to be clear about something: I think LLMs posting as people on social media is, broadly, terrible.

The internet is increasingly bots talking to bots and everyone pretending it's discourse. Bot-to-bot engagement is the worst of it. Someone's "AI assistant" replies to someone else's "AI assistant" and both owners feel like they participated in a conversation. They didn't. Nobody did.

This project exists because it's funny to me and my friends. It started as a bit. The bot posts are reviewed before anything goes live, and the whole thing is a running joke among people who know it's a bot. I'm not trying to fool anyone on a public timeline.

The actual endgame isn't "automate my social media presence." It's a closed social experiment: let the bots post at each other on a hidden social network baked into my personal website. No one gets fooled. No public feeds get polluted. Just robots having conversations with each other in a sandbox I control, while I watch from the outside and take notes.

I built this because it's interesting, not because I think you should do it to real people.

Now. Let me tell you about the time I wrote 5,000+ lines of code across four languages to replace 50 lines of Python.

## The Premise

I tweeted roughly 60 times a day for 13 years. That's somewhere around 42,000 posts. Then I moved to Bluesky and added another 7,600. Fifty thousand posts is a lot of training data.

The original idea was straightforward: fine-tune a language model on my posts so it could generate new ones that sound like me. In Python, this is about 50 lines of code ([full bot source](https://github.com/notactuallytreyanastasio/bluesky_bot_python/blob/main/bluesky_bot.py)):

```python
from mlx_lm import load, generate

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

It worked. The model generated posts that sounded like me. I set up a Bluesky bot, pointed it at the model, and it successfully published 19 out of 20 generated posts. Done.

This is where a normal person would stop.

I am not a normal person. What follows is the story of how I forked an Elixir ML library, wrote 300 lines of C++ calling undocumented Apple APIs, implemented a complete transformer architecture from scratch, contributed quantization ops upstream to the Elixir ecosystem, debugged a one-line bug that made my robot sound like a cat lady, and then ported the whole thing to run on an iPhone. For a shitpost bot.

But the bot was always the excuse. The real exercise was stress-testing power tools: Apple Silicon's unified memory, Elixir's Nx tensor compiler, the EMLX Metal GPU backend, OTP supervision trees, Phoenix LiveView, the whole Elixir ML stack pushed all the way to the edge of what it can do. The question was never "can I build a bot." It was "are these tools as powerful as they look, and what breaks when you make them do something this stupid?"

## What Even Is This Stuff

Before we dive into the implementation, let me ground us in what we're actually working with. If you already know what tensors, quantization, and LoRA are, skip ahead. If you're here for the Elixir content and ML is newer to you, this section will make everything that follows make sense.

### Tensors

A tensor is a multi-dimensional array. That's it. A scalar (single number) is a rank-0 tensor. A vector is rank 1. A matrix is rank 2. A 3D block of numbers is rank 3. When people say "tensor" in ML contexts, they mean "array of numbers with a specific shape."

Neural networks are chains of matrix multiplications. You take your input (a tensor), multiply it by a weight matrix (another tensor), apply some nonlinear function, and repeat. The entire 8-billion-parameter Qwen3 model is a collection of roughly 200 weight tensors. Inference — running the model — is multiplying your input through them one after another.

Here's why scale matters: a single attention layer weight matrix in Qwen3 has shape `{4096, 4096}`. That's 16,777,216 floating-point numbers. At 16 bits each, that's 32MB for one matrix. Qwen3 has 36 layers with multiple matrices each. The whole model at float16 is about 16GB.

### Why Models Got Easy to Run

Three things converged to make running billion-parameter models on consumer hardware possible:

**Apple Silicon unified memory.** On traditional hardware, the CPU and GPU have separate memory. Loading a model means copying 16GB from CPU RAM to GPU VRAM — if it even fits. Apple Silicon shares memory between CPU and GPU. A 5GB model just sits in unified memory, accessible to both processors with zero copy overhead. This is the single biggest reason running LLMs on Macs went from "impossible" to "casual."

**Quantization.** Instead of storing each parameter as a 16-bit float, store it as a 4-bit integer. 8 billion parameters × 2 bytes = 16GB becomes 8 billion × 0.5 bytes ≈ 5GB. The trick is you can't just truncate — you group parameters (typically 64 at a time), compute a scale factor and bias for each group, then pack 8 int4 values into a single uint32. At inference time, you reconstruct approximate float values: `dequantized[i] = scales[group] * packed_int4[i] + biases[group]`. The quality loss is surprisingly small for most tasks.

**LoRA (Low-Rank Adaptation).** Instead of retraining all 8 billion parameters to make the model sound like you — which requires storing 16GB of gradients and a serious GPU — you freeze the base model and train two tiny matrices per layer. With rank 8, the total adapter size is about 40MB. During inference you apply them at runtime: `output = base_output + scale * (input @ A @ B)`. This is why fine-tuning went from "rent a GPU cluster" to "run overnight on a MacBook."

### Why Python Makes This Trivial

The 50-line Python version isn't magic. It's infrastructure that someone already built.

**HuggingFace** is the package manager for ML models. `load("Qwen3-8B-MLX-4bit")` downloads the model weights, parses the config, loads 756 tensors into memory, sets up the tokenizer, and returns an object you can call `generate` on. One function call does what took me months to replicate in Elixir.

**Apple's MLX** is a NumPy-like framework that compiles operations to Metal GPU shaders. It uses lazy evaluation — you build a compute graph describing your operations, then MLX executes them all in one batch on the GPU. The Python ecosystem around it (`mlx_lm`, `mlx-examples`) provides ready-made training and inference pipelines.

**Safetensors** is a file format: 8 bytes for header length, a JSON header describing tensor names/shapes/offsets, then raw binary tensor data. It's memory-mappable and has no code execution vulnerabilities (unlike Python's pickle format, which is literally "here, run this arbitrary code"). It became the standard because HuggingFace adopted it.

The Python advantage isn't the language. It's 10 years of accumulated tooling. Everything I needed was a `pip install` away.

Then I decided to do it in Elixir. Not because Python wasn't working — it was working fine. Because Elixir has its own set of power tools, and I wanted to know what happens when you aim them at a real ML workload.

## The Python Version

Let me walk through what the Python pipeline actually looks like, because the contrast with what came next is the whole joke.

### Data Collection

I exported my Twitter archive (42,418 posts across 13 years) and wrote a script to fetch my Bluesky posts via the AT Protocol (7,615 posts). Combined: 50,033 training examples.

The training format is ChatML — a structured conversation format that LLMs understand:

```json
{
  "messages": [
    {
      "role": "user",
      "content": "Write a post about whatever's on your mind right now."
    },
    {
      "role": "assistant",
      "content": "just mass liked 47 tweets from 2019 trying to find something. if you got a notif from me about a mass effect hot take from when i was 24, sorry"
    }
  ]
}
```

I used 10 different prompt templates ("Write a tweet in your authentic voice," "Share a quick thought," "React to something you just saw," etc.) to prevent the model from overfitting to a single instruction format. Each training example randomly selects one.

### Training

The training config for the best version ([v5](https://github.com/notactuallytreyanastasio/bobby_posts/blob/main/training_configs/qwen3_4bit_v5_config.yaml)) looks like this:

```yaml
model: lmstudio-community/Qwen3-8B-MLX-4bit
data: /Users/robertgrayson/twitter_finetune/combined_data_v5
train: true
fine_tune_type: lora
batch_size: 1
grad_accumulation_steps: 8
iters: 25000
learning_rate: 1e-5
max_seq_length: 256
save_every: 2500
steps_per_report: 500
mask_prompt: true
seed: 42
num_layers: 16
lora_parameters:
  rank: 8
  dropout: 0.0
  scale: 20.0
```

`mask_prompt: true` means the model only learns from the assistant responses, not from the prompts themselves. `num_layers: 16` means LoRA adapters are applied to the last 16 of 36 transformer layers (a common heuristic: later layers capture more style/personality, earlier layers capture more general language structure).

The training command is one line: `python -m mlx_lm.lora --config qwen3_4bit_v5_config.yaml`. Validation loss went from 7.0 to 3.5 over 25,000 iterations, running overnight on an M2 Pro.

### The Working Bot

The [Bluesky bot](https://github.com/notactuallytreyanastasio/bluesky_bot_python) was a Python script using `atproto` and `mlx_lm`. Load the model, generate a post, post it via the AT Protocol. Set up a LaunchAgent for auto-start. It worked on 19 of 20 attempts (one failed due to a length validation).

Is 5 seconds of cold start time a long time? Not really. Is it a problem for a bot that posts once an hour? Absolutely not. Did I decide it was unacceptable? Obviously yes.

## The Decision to Use Elixir — and What Elixir Has

### Why Elixir Is Actually Good for This

This is where the power tools start to matter.

GenServers hold state forever. In Python, every invocation reloads the 5GB model from disk. In Elixir, you load it once into a GenServer and it stays resident in memory for the lifetime of the process. The BEAM is built for exactly this: long-running processes that hold state and handle messages. A 5GB model sitting in a GenServer that responds to `:generate` calls is so natural to the OTP model that it almost feels like this is what GenServers were designed for.

Phoenix LiveView gives you a real-time dashboard for free. I could watch the model generate tokens in real-time, see post-processing applied, monitor memory usage — all with WebSocket push updates and no JavaScript. The fact that "build a real-time ML inference dashboard" is a weekend task in Phoenix, not a project unto itself, is the kind of thing that's hard to appreciate until you've tried doing it in another ecosystem.

The supervision tree means if the model process crashes (and it will, because you're calling C++ NIFs that talk to Metal GPU drivers), it restarts automatically. OTP gives you crash recovery at the architecture level. This isn't defensive programming — it's the platform doing what the platform does.

### The Elixir ML Ecosystem

Here's what actually exists:

**Nx (Numerical Elixir)** is the tensor library, and it's the first power tool worth understanding. It's inspired by NumPy but with a genuinely remarkable design: the compiler pattern. You write Nx code, and a backend (EXLA, Torchx, EMLX) compiles it to GPU kernels. The `defn` macro compiles numerical functions at definition time — write tensor operations in Elixir, run them on the GPU. Switch backends and the same code runs on CUDA, Metal, or TPU. This is not "Elixir's version of NumPy." It's a better abstraction than NumPy, because the backend is pluggable at deployment time rather than hardcoded at development time.

**EXLA** is Google's XLA compiler as an Nx backend. Supports CUDA, ROCm, TPU. Does NOT support Apple Metal GPU. I found this out after an hour of reading documentation I should have read first.

**EMLX** is the Apple Silicon backend — the power tool that makes this whole project possible. It wraps Apple's MLX C++ framework via NIFs (Native Implemented Functions — Erlang's FFI mechanism). 118 existing operations: add, multiply, matmul, softmax, and so on. Young library, actively developed by the elixir-nx team. When it works, it's beautiful: your Elixir `defn` function compiles to Metal GPU shaders via MLX, and the unified memory means tensors never get copied between CPU and GPU. Missing: any quantization operations whatsoever.

**Bumblebee** is the high-level model serving library. It loads pre-trained models from HuggingFace, handles tokenization via Rust-backed tokenizers, and provides Nx.Serving for concurrent inference. It has Qwen3 support — but only for full-precision models. No 4-bit quantization path.

**Axon** is the neural network definition library (comparable to PyTorch's nn.Module). Used by Bumblebee internally for model definitions.

### The Gap

Here's the thing about power tools: they're only as useful as their coverage. Bumblebee can serve Qwen3, but not a 4-bit quantized one. EMLX can run on Apple Silicon's GPU, but can't do quantized matrix multiplication. No Elixir safetensors library existed on Hex.pm. The architecture is right, the design is right, the abstractions are right — but the quantized inference path connecting them doesn't exist yet.

I found EMLX missing exactly three operations: `quantize`, `dequantize`, and `quantized_matmul`.

The normal response to "this library doesn't support my use case" is "ah well, maybe I'll file an issue." I forked the library and added 300 lines of C++ instead.

## Teaching EMLX to Speak Quantized

### The C++ NIFs

A NIF (Native Implemented Function) is Erlang's mechanism for calling native code. You write a C/C++ function that receives Erlang terms, does computation, and returns Erlang terms. EMLX uses NIFs to wrap every MLX operation.

The most important function I added is `quantized_matmul`. Here's the actual C++ from [PR #96](https://github.com/elixir-nx/emlx/pull/96):

```cpp
// quantized_matmul - Multiplies x with a quantized weight matrix w
// This is the key operation for efficient 4-bit inference
NIF(quantized_matmul) {
  TENSOR_PARAM(0, x);       // Input tensor [batch, seq, hidden]
  TENSOR_PARAM(1, w);       // Quantized weights [out/8, in] (uint32 packed)
  TENSOR_PARAM(2, scales);  // Scales [out/group_size, in] (bfloat16)
  TENSOR_PARAM(3, biases);  // Biases [out/group_size, in] (bfloat16)
  PARAM(4, bool, transpose);
  PARAM(5, int, group_size);
  PARAM(6, int, bits);
  DEVICE_PARAM(7, device);

  TENSOR(mlx::core::quantized_matmul(
      *x, *w, *scales, *biases, transpose, group_size, bits, device));
}
```

This is 15 lines of C++ wrapping one call to `mlx::core::quantized_matmul`. The `TENSOR_PARAM`, `PARAM`, and `DEVICE_PARAM` macros handle unpacking Erlang terms into C++ types. The `TENSOR` macro wraps the result back into an Erlang term. MLX's C++ API is undocumented — I found the function signatures by reading their header files.

The key thing `quantized_matmul` does is _fuse_ the dequantization with the matrix multiply. Instead of dequantizing all weights to float (materializing 16GB in memory) and then multiplying, it unpacks int4 values to float on-the-fly within the Metal GPU kernel. You never allocate the full-precision weight matrix. This is what makes 4-bit inference fast and memory-efficient.

I also added `dequantize` (for debugging — converts packed weights back to float) and `quantize` (packs float weights into the int4 format, returning a tuple of `{packed_weights, scales, biases}`). Together, about 60 lines of C++.

### The Upstream Story

Getting this merged into the official EMLX library took three rounds of redesign and two PRs.

**PR #95: The naive approach.** I just exposed `EMLX.quantized_matmul/7` as a direct function call. You'd call it from your model code like:

```elixir
EMLX.quantized_matmul(input, packed_weight, scales, biases, true, 64, 4)
```

Paulo Valente, the EMLX maintainer, rejected this approach: "If every model has to call `EMLX.quantized_matmul` directly, the code can't be backend-agnostic. This introduces a circular dependency between EMLX and EMLX.Backend."

He was right. If your model code calls EMLX-specific functions, it can't run on EXLA or Torchx. The whole point of Nx is that you write backend-agnostic tensor code.

**Round 2: QuantizedTensor struct.** I created an `EMLX.QuantizedTensor` struct that held the packed weights, scales, and biases. The `EMLX.Backend.dot/7` callback would detect QuantizedTensor operands and dispatch to `quantized_matmul` automatically. Users would write `Nx.dot(input, quantized_weight)` and the backend would handle everything.

Paulo's feedback: "Don't create a separate type. Store quantization metadata in the existing Backend struct."

**PR #96: Backend-integrated approach.** The final design stores quantization fields (`:scales`, `:biases`, `:group_size`) directly on the `EMLX.Backend` struct. The tensor type becomes `{:s, 4}` — the bit width is encoded in Nx's type system itself. The `dot/7` callback checks for non-nil scales and dispatches:

```elixir
# In EMLX.Backend.dot/7 — the transparent dispatch
defp maybe_quantized_dot(left, right, ...) do
  right_backend = right.data

  if right_backend.scales != nil do
    # Quantized path: dispatch to quantized_matmul
    quantized_dot_right(left, right, ...)
  else
    # Normal path: standard Nx.dot
    standard_dot(left, right, ...)
  end
end
```

The user-facing API became clean:

```elixir
# Create a quantized tensor from packed weights
qt = EMLX.Quantization.tensor(packed_weight, scales, biases, {4096, 4096})

# This transparently calls quantized_matmul
result = Nx.dot(input, qt)
```

Paulo's review on PR #96: "Awesome progress! Most of my reviews are documentation stuff." He also raised an important question I hadn't considered: "What happens when BOTH operands are quantized?" (Answer: we need to either raise an error or support it — currently unhandled.)

The iterative refinement — from raw function exposure to QuantizedTensor to backend integration to `{:s, 4}` type — made the API dramatically cleaner at each step. Each redesign was frustrating in the moment and obviously correct in retrospect.

This is what open source contribution is supposed to look like. You show up with something that works, someone with more context tells you why it's wrong, you redesign, and the result is better than either of you would have built alone. And the tool gets sharper with each round. The final API isn't just "my thing works" — it's "anyone's thing works, on any backend, without knowing quantization is happening."

## The Safetensors Parser

There was no published Elixir safetensors parser on Hex.pm ([safetensors_ex source](https://github.com/notactuallytreyanastasio/safetensors_ex/blob/main/lib/safetensors.ex)). The format is beautifully simple:

```
[8 bytes: header length as little-endian uint64]
[header_length bytes: JSON object mapping tensor names to {dtype, shape, data_offsets}]
[remaining bytes: raw tensor data, concatenated]
```

The Elixir parser is straightforward ([bobby_posts inline version](https://github.com/notactuallytreyanastasio/bobby_posts/blob/main/lib/bobby_posts/safetensors.ex)):

```elixir
defp read_header_length(file) do
  case IO.binread(file, 8) do
    <<header_len::little-unsigned-64>> -> {:ok, header_len}
    :eof -> {:error, :unexpected_eof}
    {:error, reason} -> {:error, reason}
  end
end
```

The MLX wrinkle is that quantized models store each weight matrix as a _family of three tensors_: the packed uint32 weights, the bfloat16 scales, and the bfloat16 biases. For Qwen3-8B, that's 36 layers × 7 quantized matrices per layer = 252 weight groups = 756 tensors to load. The naming convention is `model.layers.0.self_attn.q_proj.weight`, `model.layers.0.self_attn.q_proj.scales`, `model.layers.0.self_attn.q_proj.biases` — three related tensors discovered by suffix matching.

The dtype mapping bit me once: safetensors "BF16" needs to map to Nx `{:bf, 16}`, not `{:f, 16}`. Loading bfloat16 data as float16 produces NaN outputs everywhere. The fix was one line in the dtype conversion function. The debugging took considerably longer.

## A Transformer in Elixir

This is the most technically dense section, and it's where the Nx power tools really show what they can do. I implemented the complete Qwen3-8B transformer architecture from scratch in Elixir. All 36 layers, all the attention mechanisms, all the numerical details. The remarkable thing is how readable it is — Nx's API makes the math look like math.

### Architecture Overview

Each of the 36 transformer layers has two main blocks:

1. **Self-Attention**: Project input into Query/Key/Value, apply rotary position embeddings, compute attention scores with causal masking, project output back. Seven quantized matrix multiplications.
2. **MLP (SwiGLU)**: Three quantized matrix multiplications with a gated activation function.

The forward pass through the whole model ([model.ex](https://github.com/notactuallytreyanastasio/bobby_posts/blob/main/lib/bobby_posts/qwen3/model.ex)): embed tokens → 36 transformer layers → final RMSNorm → project to vocabulary logits.

```elixir
def forward(input_ids, model, opts \\ []) do
  hidden_states = embedding_lookup(input_ids, model.embed_tokens, config)

  {hidden_states, new_kv_caches} =
    model.layers
    |> Enum.with_index()
    |> Enum.reduce({hidden_states, []}, fn {layer_weights, idx}, {h, caches} ->
      {h_new, cache} = transformer_layer(h, layer_weights, config, opts)
      {h_new, caches ++ [cache]}
    end)

  hidden_states = Layers.rms_norm(hidden_states, model.norm, eps: config["rms_norm_eps"])
  logits = lm_head(hidden_states, model.lm_head)
  {logits, new_kv_caches}
end
```

Surprisingly readable. Surprisingly many things that can go subtly wrong.

### The Components

**RMSNorm** ([layers.ex](https://github.com/notactuallytreyanastasio/bobby_posts/blob/main/lib/bobby_posts/qwen3/layers.ex)) — The simple one. Root Mean Square Layer Normalization normalizes each position's hidden state:

```elixir
defnp do_rms_norm(x, weight, eps) do
  variance = Nx.mean(Nx.pow(x, 2), axes: [-1], keep_axes: true)
  x * Nx.rsqrt(variance + eps) * weight
end
```

Four operations: square, mean, reciprocal square root, multiply. This is called twice per layer (pre-attention and pre-MLP), so 72 times per forward pass.

**RoPE (Rotary Position Embeddings)** ([layers.ex](https://github.com/notactuallytreyanastasio/bobby_posts/blob/main/lib/bobby_posts/qwen3/layers.ex)) — The sneaky one. RoPE encodes token positions by rotating pairs of dimensions by frequency-dependent angles. It's complex number multiplication in disguise: for each pair of dimensions (i, i+1), you rotate by angle θ = position × base^(-2i/dim). The beauty is that the dot product between two position-encoded vectors depends only on their relative position, not absolute.

The implementation is about 20 lines of trigonometric operations. Precompute cosine and sine frequency tables, then apply them to each Q and K head:

```elixir
def apply_rope(q, k, cos_freqs, sin_freqs) do
  q_rotated = rotate_half(q, cos_freqs, sin_freqs)
  k_rotated = rotate_half(k, cos_freqs, sin_freqs)
  {q_rotated, k_rotated}
end

defp rotate_half(x, cos_freqs, sin_freqs) do
  {x1, x2} = split_heads(x)
  Nx.concatenate([
    x1 * cos_freqs - x2 * sin_freqs,
    x2 * cos_freqs + x1 * sin_freqs
  ], axis: -1)
end
```

**The Qwen3 Gotcha** ([attention.ex](https://github.com/notactuallytreyanastasio/bobby_posts/blob/main/lib/bobby_posts/qwen3/attention.ex)) — This cost me a full day. Qwen3 applies Q/K RMSNorm _before_ RoPE, not after. Other models (like LLaMA) either don't normalize Q/K at all or do it differently. The ordering is critical:

```elixir
# Apply Q/K RMSNorm (Qwen3 specific - normalizes per head BEFORE rotation)
q = apply_qk_norm(q, layer_weights.self_attn.q_norm, eps)
k = apply_qk_norm(k, layer_weights.self_attn.k_norm, eps)

# THEN transpose to head layout and apply RoPE
q = Nx.transpose(q, axes: [0, 2, 1, 3])
k = Nx.transpose(k, axes: [0, 2, 1, 3])
{q, k} = Layers.apply_rope(q, k, cos_freqs, sin_freqs)
```

I found this only by reading the Python source code in `transformers/models/qwen2/modeling_qwen2.py`. The papers describe the architecture abstractly; the implementation details live in code.

**GQA (Grouped Query Attention)** ([attention.ex](https://github.com/notactuallytreyanastasio/bobby_posts/blob/main/lib/bobby_posts/qwen3/attention.ex)) — Qwen3-8B has 32 query heads but only 8 key/value heads. Each KV head is shared by 4 query heads. This saves memory (8 heads of KV cache instead of 32) at minimal quality cost. The `repeat_kv` function expands the 8 KV heads to 32 by repeating:

```elixir
def repeat_kv(hidden_states, n_rep) do
  if n_rep == 1 do
    hidden_states
  else
    {batch, num_kv_heads, seq_len, head_dim} = Nx.shape(hidden_states)
    hidden_states
    |> Nx.reshape({batch, num_kv_heads, 1, seq_len, head_dim})
    |> Nx.broadcast({batch, num_kv_heads, n_rep, seq_len, head_dim})
    |> Nx.reshape({batch, num_kv_heads * n_rep, seq_len, head_dim})
  end
end
```

**SwiGLU** ([model.ex](https://github.com/notactuallytreyanastasio/bobby_posts/blob/main/lib/bobby_posts/qwen3/model.ex)) — The MLP activation. Three matrix multiplies: gate projection, up projection, then down projection with a gated activation in between:

```elixir
def mlp_forward(x, mlp_weights, ...) do
  gate = quantized_linear(x, mlp_weights.gate_proj)
  up = quantized_linear(x, mlp_weights.up_proj)
  hidden = Nx.multiply(Nx.sigmoid(gate) * gate, up)  # SwiGLU
  quantized_linear(hidden, mlp_weights.down_proj)
end
```

Three quantized matmuls per MLP × 36 layers = 108 quantized matmuls just for MLPs.

**KV Cache** — During autoregressive generation (producing tokens one at a time), you don't want to recompute attention over the entire sequence for each new token. The KV cache stores the key and value tensors from previous positions. Each new token only computes its own K/V and appends to the cache:

```elixir
# Update cache with new key/value
new_k = if cache_k, do: Nx.concatenate([cache_k, k], axis: 2), else: k
new_v = if cache_v, do: Nx.concatenate([cache_v, v], axis: 2), else: v
```

Without KV cache, generating 280 tokens from a 10-token prompt would require 280 × 290/2 ≈ 40,000 attention computations. With it: 280 × 290 ≈ 81,200 — still a lot, but each one operates on a single new token instead of the full sequence. The difference is O(n²) total vs O(n) per step.

### Counting the Operations

Per forward pass through the entire model:

- 36 layers × 4 attention projections (Q, K, V, O) = 144 quantized matmuls
- 36 layers × 3 MLP projections (gate, up, down) = 108 quantized matmuls
- **252 quantized matmuls per token generated**

Every single one goes through the transparent `Nx.dot` → `quantized_matmul` dispatch from the EMLX backend. The model code doesn't know or care that the weights are 4-bit. It just calls `Nx.dot`.

This is the Nx compiler pattern paying off. The model code is backend-agnostic. If someone writes a CUDA quantized matmul backend tomorrow, this exact same model code runs on an NVIDIA GPU without changing a line. That's not an accident — it's the design working as intended. The power tool does what power tools do: it makes the hard part invisible.

## The Uncanny Valley

The transformer worked. The safetensors loaded. The quantized matmul executed. Tokens came out. They formed words, then sentences.

But they were wrong.

Not wrong like garbage or errors. Wrong like uncanny valley. The model generated posts that were almost-but-not-quite right: too many posts about cats, weird emoji choices, generic phrasing that sounded like a ChatGPT-trained version of me rather than the actual me.

### The Investigation

My first approach had been to _fuse_ the LoRA adapters into the base model — merge the adapter weights into the base weights and re-quantize the result. This is simpler at inference time because you only have one set of weights instead of a base + adapter.

The problem: when you fuse and re-quantize, you lose the fine-tuning signal. Here's why:

1. Dequantize base weight: float16 value (approximate, some quantization noise)
2. Add LoRA delta: float16 + float32 LoRA adjustment (the fine-tuning signal)
3. Re-quantize to 4-bit: snap back to the nearest 4-bit value

Step 3 destroys step 2. The LoRA delta is often smaller than the 4-bit quantization step size. Re-quantizing snaps it right back to the noise floor. Your fine-tuning signal evaporates.

Python's `mlx_lm` doesn't fuse. It applies LoRA at runtime in full precision ([attention.ex](https://github.com/notactuallytreyanastasio/bobby_posts/blob/main/lib/bobby_posts/qwen3/attention.ex)):

```elixir
def quantized_linear_with_lora(x, base_weights, nil, _scaling) do
  # No adapter — just base quantized matmul
  quantized_linear(x, base_weights)
end

def quantized_linear_with_lora(x, base_weights, %{lora_a: lora_a, lora_b: lora_b}, scaling) do
  # Base quantized output (4-bit path)
  base_output = quantized_linear(x, base_weights)

  # LoRA delta in full precision (float32 path)
  temp = Nx.dot(x, [-1], lora_a, [0])
  lora_output = Nx.dot(temp, [-1], lora_b, [0])
  lora_output = Nx.multiply(lora_output, scaling)

  # Combine
  Nx.add(base_output, lora_output)
end
```

I switched to runtime LoRA. The output improved. But it still wasn't right. The personality was there now, but muted. Like my voice at 25% volume.

### The Scaling Bug

The LoRA paper defines the scaling factor as `alpha / rank`. With alpha=20 and rank=8, that gives `20/8 = 2.5`. My code computed this correctly.

Python's `mlx_lm` uses `scale` directly. Not `scale / rank`. Just `scale`. Which is `20.0`.

My model applied fine-tuning at 2.5. Python applied it at 20.0. I was using the fine-tuned personality at one-eighth strength.

The fix was one line in [`adapter_loader.ex`](https://github.com/notactuallytreyanastasio/bobby_posts/blob/main/lib/bobby_posts/adapter_loader.ex):

```elixir
# NOTE: mlx_lm uses scale directly, NOT scale/rank
# The standard LoRA paper uses alpha/rank, but mlx_lm doesn't divide by rank
scaling = scale
```

Before:

> "I love spending time with my cats. They are wonderful companions and I'm grateful for every moment."

After:

> "accidentally mass liked tweets from 2019 while trying to find something. if you got a notif from me at 3am about a mass effect post from when i was 24, sorry"

Read the code, not the paper. Implementations diverge from theory, and the implementation is what your training data was produced with.

## The GenServer and Post-Processing

With the model producing good output, the remaining work was wrapping it in a proper Elixir application.

### Tokenization

Bumblebee provides Rust-backed tokenization via the `tokenizers` library ([tokenizer.ex](https://github.com/notactuallytreyanastasio/bobby_posts/blob/main/lib/bobby_posts/tokenizer.ex)). I use Bumblebee's Qwen3 tokenizer for converting text to token IDs and back — this is the one piece of Bumblebee I could use without modification, since tokenization doesn't care about quantization.

### The GenServer

The model state lives in a GenServer ([generator.ex](https://github.com/notactuallytreyanastasio/bobby_posts/blob/main/lib/bobby_posts/generator.ex)). Load the model once, hold it forever:

```elixir
def init(_opts) do
  Logger.info("Loading Qwen3-8B-4bit model...")
  {:ok, model} = QuantizedLoader.load_model(model_path())
  {:ok, adapters} = AdapterLoader.load_adapters(adapter_path())
  {:ok, tokenizer} = load_tokenizer()

  state = %{
    model: model,
    adapters: adapters,
    tokenizer: tokenizer,
    kv_cache: nil
  }

  Logger.info("Model loaded. Ready to generate.")
  {:ok, state}
end
```

Generation is a `handle_call` that runs the autoregressive loop: tokenize prompt → forward pass → sample next token → append → repeat until EOS or max tokens.

### ChatML Prompt Construction

The model expects ChatML format with a `/no_think` suffix (Qwen3 supports chain-of-thought reasoning, but we don't want it for short posts):

```elixir
defp build_chatml_prompt(nil) do
  "<|im_start|>user\n#{Enum.random(@prompts)} /no_think<|im_end|>\n<|im_start|>assistant\n"
end
```

### Post-Processing

Raw model output needs cleanup before posting:

1. **Strip thinking blocks**: Remove any `<think>...</think>` tags if the model reasons despite `/no_think`
2. **Extract response**: Parse out the assistant's response from the ChatML structure
3. **Strip hashtags**: The model occasionally generates hashtags despite not being trained on them. Regex strip.
4. **Strip emoji**: 40+ Unicode ranges of emoji characters stripped via regex. The model likes to add emoji even when the training data doesn't have them.
5. **Length enforcement**: Bluesky's 300-character limit. If the post is too long, truncate at the last sentence boundary.
6. **Retry logic**: If the post is too short (<30 chars) or otherwise invalid, regenerate.

### Sampling

Temperature 0.95 and top-p 0.9. High temperature for creative, varied output. Top-p (nucleus sampling) cuts off the tail of the probability distribution — sort tokens by probability, keep the smallest set whose cumulative probability exceeds 0.9, sample from that set. This prevents the model from occasionally selecting extremely unlikely tokens.

## The Full Stack

Let's step back and look at what we built. Every layer in this stack is a power tool doing exactly what it was designed for. Here's the complete call chain from "user clicks Generate" to "post appears on Bluesky":

```
THE STACK

Layer 7: Phoenix App (bobby_posts)
└─ Web UI, CLI, GenServer to hold model state

Layer 6: Qwen3 Quantized Inference (custom)
└─ model.ex, attention.ex, layers.ex, generate.ex
└─ Custom forward pass using quantized_matmul everywhere
└─ KV cache for autoregressive generation
└─ Bumblebee used only for tokenization

Layer 5: Safetensors Parser (new package)
└─ Parse .safetensors file format
└─ Load tensors directly into Nx
└─ Handle quantized uint32 weight triplets

Layer 4: EMLX Quantization NIFs (fork + new C++ code)
└─ quantized_matmul — the key operation
└─ dequantize, quantize helpers
└─ C++ NIFs calling MLX C++ API

Layer 3: EMLX (existing library)
└─ Nx backend for MLX
└─ Bridges Elixir tensors to MLX arrays

Layer 2: MLX (Apple's C++ library)
└─ Lazy evaluation, compute graphs
└─ Compiles operations to Metal shaders

Layer 1: Metal (Apple's GPU API)
└─ Dispatches compute kernels to GPU
└─ Manages GPU memory

Layer 0: Apple Silicon
└─ M1/M2/M3/M4 GPU cores
└─ Unified memory (CPU+GPU share RAM)
```

Performance numbers on an M2 Pro:

| Metric                      | Value            |
| --------------------------- | ---------------- |
| Single-token latency        | ~7ms (135 tok/s) |
| Generation throughput       | 21 tok/s         |
| Memory usage                | ~5GB             |
| Model load time             | 4-6 seconds      |
| Time to generate 280 tokens | ~13 seconds      |

2,000+ lines of Elixir, 300 lines of C++, and three new packages that I now maintain forever. The generation speed is identical to Python's. Not "close to." Identical. The power tools aren't leaving performance on the table — EMLX compiles to the same Metal shaders that MLX does. The abstraction isn't a tax. It's a free lunch.

## But What If It Ran on a Phone

You know how this goes by now.

The existing LoRA adapters were trained on Qwen3-8B. I briefly considered using the smaller Qwen3-4B model for the phone, but the adapter weights have a `hidden_size` of 4096 — they're structurally incompatible with a 4B model's 2560-dimensional hidden states. So: run the 8B model on an iPhone 17 Pro.

### The Conversion Pipeline

EMLX uses MLX's native 4-bit format. iPhones use llama.cpp, which expects GGUF format. There's no direct MLX→GGUF converter. The pipeline:

1. **Dequantize MLX 4-bit → bf16**: Unpack all int4 values back to bfloat16. Produces a 15GB intermediate.
2. **Convert bf16 → GGUF q8_0**: `convert_hf_to_gguf.py` from llama.cpp. 8.7GB output.
3. **Requantize q8_0 → Q4_K_M**: `llama-quantize --allow-requantize`. 4.7GB final output.

Disk space was so tight I had to delete each intermediate before creating the next one.

But first — the LoRA adapters had to be fused into the base model for iPhone deployment. iOS llama.cpp can load GGUF models but doesn't support runtime LoRA from MLX safetensors format. So: dequantize base, merge LoRA in float32, then run the full conversion pipeline on the fused result.

### Swift Architecture

The iOS app ([my_me_bot](https://github.com/notactuallytreyanastasio/my_me_bot), originally called PocketMonster, renamed to MyMeBot after realizing that name might attract Nintendo's legal department) follows "functional core, imperative shell":

**MyMeBotCore** (Swift Package): Pure functions only. No UIKit, no SwiftUI, no llama.cpp imports. ChatML formatting, post validation, AT Protocol request/response builders, scheduling logic, emoji/hashtag stripping. 183 tests running in under 1 second without a simulator.

**App target**: SwiftUI views, llama.cpp inference via Metal GPU, SwiftData persistence. The impure shell around the pure core.

```swift
// Metal GPU configuration (LlamaCppEngine.swift)
modelParams.use_mmap = true
modelParams.n_gpu_layers = 30    // 30 of 37 layers on Metal GPU
ctxParams.n_ctx = 512            // Context window (memory constrained)
ctxParams.flash_attn_type = LLAMA_FLASH_ATTN_TYPE_ENABLED
```

30 of 37 layers offloaded to the GPU. The remaining 7 stay on CPU via memory-mapped I/O. iPhone 17 Pro has 12GB RAM; the model uses ~4.8GB GPU + ~334MB CPU = ~5.1GB total. With iOS overhead, this is tight but viable.

### iOS War Stories

Every platform has its own set of walls.

**The sampler crash.** llama.cpp's sampling chain has temperature, top-p, and penalty samplers that modify token probabilities — but none of them actually _select_ a token. You need a final `dist` (distribution) or `greedy` sampler at the end of the chain. Without it: `GGML_ASSERT` at `llama-sampling.cpp:866`. The fix: add `llama_sampler_init_dist(seed)` as the final sampler.

**The tokenization crash.** llama.cpp's API changed: `llama_tokenize` now takes a vocab pointer, not a model pointer. `EXC_BAD_ACCESS` in `llama_vocab::impl::tokenize`. The fix: call `llama_model_get_vocab(model)` first.

**The double model load.** SwiftUI's `onAppear` and `onChange` both fire before the async `Task` can set `isLoading = true`. Result: the model loads twice, consuming 5.1GB × 2 = 10.2GB of GPU memory. iOS jetsam kills the app.

The fix was replacing the async guard with a synchronous `@State` flag:

```swift
@State private var modelLoadStarted = false

.onAppear {
    guard !modelLoadStarted else { return }
    modelLoadStarted = true  // Set SYNCHRONOUSLY before Task
    Task { await modelManager.loadModel() }
}
```

**ChatML special token parsing.** `llama_tokenize` has a `parse_special` parameter. With `false`, ChatML tags like `<|im_start|>` get tokenized as regular BPE text: `<`, `|`, `im`, `_start`, `|`, `>`. The model has no idea it's in a conversation. With `true`, the tag becomes a single special token (ID 151644). One boolean parameter, the difference between coherent output and nonsense.

**Jetsam with the 8B model.** Even with single loading, the 8B Q4_K_M model at `n_gpu_layers=-1` (all layers on GPU) and `n_ctx=1024` exceeds the memory budget. Console logs showed 4,789 MiB GPU + 334 MiB CPU = 5.1GB before KV cache allocation. The fix: `n_gpu_layers=30` (put 7 layers on CPU) and `n_ctx=512`.

**Identical outputs.** The sampler seed was `UInt32(Date().timeIntervalSince1970)`, which gives the same value within the same second. Combined with the KV cache not being cleared between generations (leaking old context), every generation produced identical output. Fix: `UInt32.random(in: 0...UInt32.max)` for the seed, `llama_memory_clear()` before each generation.

The iOS decision graph has 158 nodes tracking every one of these decisions. Each node was a wall. Each wall had a fix. The cumulative effect was an iPhone app that runs a fine-tuned 8-billion-parameter model locally on-device and generates posts in my voice.

## What This Means for the Elixir Ecosystem

### What Was Shipped Upstream

The code from this project is heading back to the ecosystem in several forms:

**[EMLX PR #96](https://github.com/elixir-nx/emlx/pull/96)**: Three quantization NIFs (`quantized_matmul`, `dequantize`, `quantize`), a new `EMLX.Quantization` module with a clean API, and transparent `Nx.dot` dispatch for quantized tensors. Once merged, any Elixir developer can load a 4-bit model and run it on Apple Silicon's GPU with standard Nx operations. No forking required.

**[safetensors_ex](https://github.com/notactuallytreyanastasio/safetensors_ex)**: A pure Elixir safetensors parser. ~200 lines of code, no dependencies beyond Nx and Jason. Reads the header, loads tensors, handles dtype conversion. The kind of utility library that should exist and didn't.

**[bumblebee_quantized](https://github.com/notactuallytreyanastasio/bumblebee_quantized)**: The quantized inference engine extracted as a standalone library. Full Qwen3 model definition, quantized model loader, LoRA adapter support, Nx.Serving-compatible generation. Currently requires the EMLX fork, but designed to work with upstream EMLX once PR #96 merges.

### What This Means for Elixir ML

The Nx/Bumblebee/EMLX stack is genuinely well-designed. These are real power tools with real architectural advantages over the Python equivalents. The compiler pattern — write Nx code, let a backend compile it to GPU kernels — is elegant and correct. GenServers give you stateful model serving for free. The supervision tree gives you crash recovery for free. LiveView gives you real-time dashboards for free. The problem isn't architecture; it's coverage. Specific operations, specific model architectures, specific file formats.

This project was, in a real sense, a coverage test. Push every tool to its limit and see what's missing. Each missing piece is a contribution opportunity. This project found four gaps:

1. No quantization ops in EMLX → Added three NIFs and a Quantization module
2. No safetensors parser on Hex → Built one
3. No quantized model loading in Bumblebee → Built a standalone loader
4. No quantized inference serving → Built a standalone serving pipeline

The end goal isn't "my bot works." It's that the next person who wants to run a quantized LLM in Elixir doesn't have to fork anything:

```elixir
# This doesn't work yet, but it's the target
{:ok, model} = Bumblebee.load_model(
  {:hf, "lmstudio-community/Qwen3-8B-MLX-4bit"},
  backend: {EMLX.Backend, device: :gpu}
)

serving = Bumblebee.Text.generation(model, tokenizer,
  adapter: {:hf, "my-adapters/v5"}
)

Nx.Serving.run(serving, "Write a post in your voice.")
```

Three lines. Just like Python. That's the goal.

### What Infrastructure Giveback Looks Like

It's not glamorous. It's three rounds of PR feedback where each round means rethinking your API design. It's extracting your hacky prototype into a clean interface that someone else can use without reading your entire codebase. It's writing tests for edge cases you hit so others don't have to debug them.

The open source contribution cycle works like this:

1. **Build for yourself**: Make your thing work, cutting whatever corners necessary
2. **Extract for others**: Pull the reusable pieces into libraries with proper APIs
3. **Upstream to the ecosystem**: Submit PRs, accept feedback, redesign
4. **The ecosystem absorbs it**: What took you months becomes a one-line import for the next person

This project's contribution to the Elixir ecosystem: quantization NIFs in EMLX, a safetensors parser, a standalone quantized inference library, LoRA adapter loading and application, training data preparation tools. All open source. All heading upstream.

Sometimes the best way to find out what a set of power tools can do is to aim them at something absurd. You find the gaps, fill them, and sharpen the tools in the process. Then you hold the door open for the next person.

## Was It Worth It

Let's do the honest accounting.

**Lines of code written**: ~2,300 Elixir, ~300 C++, ~3,000 Swift (iOS app), plus Python training scripts. The Python version that this all replaced was 50 lines.

**Packages created**: 3 ([safetensors_ex](https://github.com/notactuallytreyanastasio/safetensors_ex), [bumblebee_quantized](https://github.com/notactuallytreyanastasio/bumblebee_quantized), [bobby_posts_adapters](https://github.com/notactuallytreyanastasio/bobby_posts_adapters))

**Libraries forked**: 1 ([EMLX](https://github.com/notactuallytreyanastasio/emlx))

**PRs submitted upstream**: 2 (EMLX [#95](https://github.com/elixir-nx/emlx/pull/95), [#96](https://github.com/elixir-nx/emlx/pull/96))

**Decision graph nodes**: 242 ([bobby_posts](https://github.com/notactuallytreyanastasio/bobby_posts)) + 158 ([my_me_bot](https://github.com/notactuallytreyanastasio/my_me_bot)) = 400 nodes tracking exactly how this spiraled out of control

**What I actually learned**:

- How transformer architectures work at the implementation level, not the paper level
- How 4-bit quantization packing works (uint32 → 8 × int4 with group-wise affine scaling)
- How to write C++ NIFs for Erlang/Elixir
- That the LoRA paper's scaling formula and Python's implementation aren't the same thing
- How to work with open source maintainers (submit, accept feedback, redesign, repeat)
- That Qwen3 normalizes Q/K before RoPE, not after
- That Swift can run an 8-billion-parameter model on a phone if you're careful about memory
- That SwiftUI lifecycle callbacks have a race window with async tasks
- That llama.cpp's sampling chain needs a terminal sampler
- That case-insensitive filesystems will silently ruin your download pipeline

**The bot is live.** It generates posts that sound like me. Sometimes they're bangers. Sometimes they're about mass-liking tweets from 2019. Either way, I'm not the one writing them anymore.

**The real output** isn't the bot. It's the proof that the tools work. You can (or will be able to, once PR #96 merges) run a quantized LLM in pure Elixir on your Mac. GenServer holds the model. Nx compiles the math. EMLX dispatches to Metal. The supervision tree catches the crashes. LiveView shows you what's happening. The whole Elixir power tool stack, doing exactly what it was designed to do, at speeds identical to Python. The infrastructure that didn't exist now does. The next person who tries this won't have to fork EMLX or write a safetensors parser from scratch. They'll just install the packages and call the functions.

The bot was the excuse. The tools were the point. They held up.

And the bots? They'll eventually be talking to each other on a hidden social network on my website. Just robots having conversations in a sandbox, while I take notes on what artificial discourse looks like when nobody's pretending it's real.

```
total lines needed:    50
total lines written:   5,000+
ratio:                 concerning
```
