defmodule Blog.PokeAround.AI.Axon.TextClassifier do
  @moduledoc """
  Axon-based multi-label text classifier for link tagging.

  Uses a simple but effective architecture:
  1. Word-level tokenization
  2. Embedding layer
  3. Global average pooling
  4. Dense layers with dropout
  5. Sigmoid output for multi-label classification

  ## Training

      # Load training data
      {inputs, labels, vocab, tag_index} = TextClassifier.prepare_training_data()

      # Build and train model
      model = TextClassifier.build_model(vocab_size: map_size(vocab), num_tags: map_size(tag_index))
      trained_state = TextClassifier.train(model, inputs, labels)

      # Save for later use
      TextClassifier.save_model(trained_state, vocab, tag_index, "priv/models/tagger")

  ## Inference

      # Load saved model
      {model, state, vocab, tag_index} = TextClassifier.load_model("priv/models/tagger")
      serving = TextClassifier.create_serving(model, state, vocab, tag_index)

      # Predict
      tags = TextClassifier.predict(serving, "Some post about JavaScript and React")
      # => ["javascript", "react", "web-dev"]
  """

  require Logger

  alias Blog.Repo
  alias Blog.PokeAround.{Link, Tag, LinkTag}
  import Ecto.Query

  # Model hyperparameters
  @max_sequence_length 128
  @embedding_dim 64
  @hidden_dim 128
  @dropout_rate 0.3
  @min_tag_count 5
  @prediction_threshold 0.3

  # Special tokens
  @pad_token "<PAD>"
  @unk_token "<UNK>"

  # ---------------------------------------------------------------------------
  # Data Preparation
  # ---------------------------------------------------------------------------

  @doc """
  Load and prepare training data from the database.

  Returns {inputs, labels, vocab, tag_index} where:
  - inputs: Nx tensor of tokenized sequences [batch, seq_len]
  - labels: Nx tensor of multi-hot labels [batch, num_tags]
  - vocab: map of word -> index
  - tag_index: map of tag_slug -> index
  """
  def prepare_training_data(opts \\ []) do
    min_tag_count = opts[:min_tag_count] || @min_tag_count

    Logger.info("Loading training data from database...")

    # Get all tagged links with their tags
    data = load_tagged_links()
    Logger.info("Loaded #{length(data)} tagged links")

    # Build vocabulary from all texts
    vocab = build_vocabulary(data)
    Logger.info("Built vocabulary with #{map_size(vocab)} words")

    # Get tags that appear at least min_tag_count times
    tag_index = build_tag_index(min_tag_count)
    Logger.info("Using #{map_size(tag_index)} tags (min count: #{min_tag_count})")

    # Filter to only include samples that have at least one of our target tags
    filtered_data = filter_samples_with_target_tags(data, tag_index)
    Logger.info("#{length(filtered_data)} samples have target tags")

    # Convert to tensors
    {inputs, labels} = to_tensors(filtered_data, vocab, tag_index)

    {inputs, labels, vocab, tag_index}
  end

  @doc """
  Load and prepare training data from the JSON file (priv/ml/training_data.json).

  This uses the manually curated training data with consolidated tags.
  """
  def prepare_training_data_from_file(opts \\ []) do
    min_tag_count = opts[:min_tag_count] || 2
    file_path = opts[:file] || "priv/ml/training_data.json"

    Logger.info("Loading training data from #{file_path}...")

    # Load JSON file
    data =
      file_path
      |> File.read!()
      |> Jason.decode!()
      |> Enum.map(fn item ->
        %{
          text: item["text"],
          domain: item["domain"],
          tags: item["tags"]
        }
      end)

    Logger.info("Loaded #{length(data)} samples from file")

    # Build vocabulary from all texts
    vocab = build_vocabulary(data)
    Logger.info("Built vocabulary with #{map_size(vocab)} words")

    # Build tag index from the training data itself (not database)
    tag_index = build_tag_index_from_data(data, min_tag_count)
    Logger.info("Using #{map_size(tag_index)} tags (min count: #{min_tag_count})")

    # Filter to only include samples that have at least one of our target tags
    filtered_data = filter_samples_with_target_tags(data, tag_index)
    Logger.info("#{length(filtered_data)} samples have target tags")

    # Convert to tensors
    {inputs, labels} = to_tensors(filtered_data, vocab, tag_index)

    {inputs, labels, vocab, tag_index}
  end

  defp build_tag_index_from_data(data, min_count) do
    data
    |> Enum.flat_map(& &1.tags)
    |> Enum.frequencies()
    |> Enum.filter(fn {_tag, count} -> count >= min_count end)
    |> Enum.sort_by(fn {_tag, count} -> -count end)
    |> Enum.map(fn {tag, _count} -> tag end)
    |> Enum.with_index()
    |> Map.new()
  end

  defp load_tagged_links do
    from(l in Link,
      where: not is_nil(l.tagged_at),
      where: not is_nil(l.post_text),
      select: %{id: l.id, text: l.post_text, domain: l.domain}
    )
    |> Repo.all()
    |> Enum.map(fn link ->
      tags = from(t in Tag,
        join: lt in LinkTag, on: lt.tag_id == t.id,
        where: lt.link_id == ^link.id,
        select: t.slug
      ) |> Repo.all()

      Map.put(link, :tags, tags)
    end)
  end

  defp build_vocabulary(data) do
    # Start with special tokens
    vocab = %{@pad_token => 0, @unk_token => 1}

    # Tokenize all texts and count word frequencies
    word_counts =
      data
      |> Enum.flat_map(fn %{text: text, domain: domain} ->
        tokenize(text) ++ tokenize(domain || "")
      end)
      |> Enum.frequencies()

    # Keep words that appear at least twice
    word_counts
    |> Enum.filter(fn {_word, count} -> count >= 2 end)
    |> Enum.sort_by(fn {_word, count} -> -count end)
    |> Enum.with_index(2)  # Start from 2 (0=PAD, 1=UNK)
    |> Enum.reduce(vocab, fn {{word, _count}, idx}, acc ->
      Map.put(acc, word, idx)
    end)
  end

  defp build_tag_index(min_count) do
    from(t in Tag,
      where: t.usage_count >= ^min_count,
      where: t.slug != "needs-review",  # Exclude error tag
      where: t.slug != "untagged",
      order_by: [desc: t.usage_count],
      select: t.slug
    )
    |> Repo.all()
    |> Enum.with_index()
    |> Map.new()
  end

  defp filter_samples_with_target_tags(data, tag_index) do
    Enum.filter(data, fn %{tags: tags} ->
      Enum.any?(tags, &Map.has_key?(tag_index, &1))
    end)
  end

  defp to_tensors(data, vocab, tag_index) do
    _num_samples = length(data)
    _num_tags = map_size(tag_index)

    # Tokenize and pad sequences
    sequences =
      data
      |> Enum.map(fn %{text: text, domain: domain} ->
        tokens = tokenize(text) ++ tokenize(domain || "")
        encode_sequence(tokens, vocab)
      end)

    # Create multi-hot labels
    labels_list =
      Enum.map(data, fn %{tags: tags} ->
        create_multi_hot(tags, tag_index)
      end)

    inputs = Nx.tensor(sequences, type: :s32)
    labels = Nx.tensor(labels_list, type: :f32)

    Logger.info("Created tensors: inputs #{inspect(Nx.shape(inputs))}, labels #{inspect(Nx.shape(labels))}")

    {inputs, labels}
  end

  defp encode_sequence(tokens, vocab) do
    tokens
    |> Enum.take(@max_sequence_length)
    |> Enum.map(fn token ->
      Map.get(vocab, token, Map.fetch!(vocab, @unk_token))
    end)
    |> pad_sequence(@max_sequence_length, Map.fetch!(vocab, @pad_token))
  end

  defp pad_sequence(tokens, max_len, pad_value) do
    current_len = length(tokens)
    if current_len >= max_len do
      tokens
    else
      tokens ++ List.duplicate(pad_value, max_len - current_len)
    end
  end

  defp create_multi_hot(tags, tag_index) do
    num_tags = map_size(tag_index)
    base = List.duplicate(0.0, num_tags)

    Enum.reduce(tags, base, fn tag, acc ->
      case Map.get(tag_index, tag) do
        nil -> acc
        idx -> List.replace_at(acc, idx, 1.0)
      end
    end)
  end

  # ---------------------------------------------------------------------------
  # Tokenization
  # ---------------------------------------------------------------------------

  @doc """
  Simple word-level tokenizer.
  """
  def tokenize(text) when is_binary(text) do
    text
    |> String.downcase()
    |> String.replace(~r/https?:\/\/\S+/, " ")  # Remove URLs
    |> String.replace(~r/[^\w\s]/, " ")  # Remove punctuation
    |> String.split(~r/\s+/, trim: true)
    |> Enum.filter(&(String.length(&1) > 1))  # Remove single chars
  end

  def tokenize(_), do: []

  # ---------------------------------------------------------------------------
  # Model Architecture
  # ---------------------------------------------------------------------------

  @doc """
  Build the Axon model for multi-label classification.
  """
  def build_model(opts \\ []) do
    vocab_size = opts[:vocab_size] || raise "vocab_size required"
    num_tags = opts[:num_tags] || raise "num_tags required"
    embedding_dim = opts[:embedding_dim] || @embedding_dim
    hidden_dim = opts[:hidden_dim] || @hidden_dim
    dropout_rate = opts[:dropout_rate] || @dropout_rate

    Axon.input("input", shape: {nil, @max_sequence_length})
    |> Axon.embedding(vocab_size, embedding_dim, name: "embedding")
    |> Axon.global_avg_pool(name: "global_pool")
    |> Axon.dense(hidden_dim, activation: :relu, name: "dense1")
    |> Axon.dropout(rate: dropout_rate, name: "dropout1")
    |> Axon.dense(hidden_dim, activation: :relu, name: "dense2")
    |> Axon.dropout(rate: dropout_rate, name: "dropout2")
    |> Axon.dense(num_tags, activation: :sigmoid, name: "output")
  end

  # ---------------------------------------------------------------------------
  # Training
  # ---------------------------------------------------------------------------

  @doc """
  Train the model on the prepared data.
  """
  def train(model, inputs, labels, opts \\ []) do
    epochs = opts[:epochs] || 20
    batch_size = opts[:batch_size] || 32
    learning_rate = opts[:learning_rate] || 0.001

    # Split into train/val
    num_samples = Nx.axis_size(inputs, 0)
    split_idx = round(num_samples * 0.9)

    train_inputs = Nx.slice(inputs, [0, 0], [split_idx, @max_sequence_length])
    train_labels = Nx.slice(labels, [0, 0], [split_idx, Nx.axis_size(labels, 1)])
    val_inputs = Nx.slice(inputs, [split_idx, 0], [num_samples - split_idx, @max_sequence_length])
    val_labels = Nx.slice(labels, [split_idx, 0], [num_samples - split_idx, Nx.axis_size(labels, 1)])

    Logger.info("Training on #{split_idx} samples, validating on #{num_samples - split_idx}")

    # Create batched streams
    train_data =
      Stream.zip(
        Nx.to_batched(train_inputs, batch_size),
        Nx.to_batched(train_labels, batch_size)
      )
      |> Stream.map(fn {x, y} -> {%{"input" => x}, y} end)

    val_data =
      [{%{"input" => val_inputs}, val_labels}]

    # Define loss and optimizer
    loss = &Axon.Losses.binary_cross_entropy(&1, &2, reduction: :mean)
    optimizer = Polaris.Optimizers.adam(learning_rate: learning_rate)

    # Train (BCE loss is the key metric for multi-label)
    model
    |> Axon.Loop.trainer(loss, optimizer)
    |> Axon.Loop.validate(model, val_data)
    |> Axon.Loop.run(train_data, %{}, epochs: epochs, compiler: EXLA)
  end

  @doc """
  Calculate multi-label accuracy (IoU style) for evaluation.
  """
  def multi_label_accuracy(y_pred, y_true) do
    # Threshold predictions
    predictions = Nx.greater(y_pred, 0.5)
    targets = Nx.greater(y_true, 0.5)

    # Calculate per-sample accuracy (intersection over union style)
    # Cast to f32 for proper division (logical ops return u8)
    correct = Nx.sum(Nx.logical_and(predictions, targets), axes: [1]) |> Nx.as_type(:f32)
    total = Nx.sum(Nx.logical_or(predictions, targets), axes: [1]) |> Nx.as_type(:f32)

    # Avoid division by zero
    total = Nx.max(total, 1.0)

    Nx.mean(Nx.divide(correct, total)) |> Nx.to_number()
  end

  # ---------------------------------------------------------------------------
  # Saving and Loading
  # ---------------------------------------------------------------------------

  @doc """
  Save trained model, vocabulary, and tag index.
  """
  def save_model(model_state, vocab, tag_index, path) do
    File.mkdir_p!(path)

    # Save model state
    state_binary = Nx.serialize(model_state)
    File.write!(Path.join(path, "model_state.nx"), state_binary)

    # Sanitize vocab keys to valid UTF-8 (some posts have invalid encoding)
    sanitized_vocab =
      vocab
      |> Enum.filter(fn {k, _v} -> String.valid?(k) end)
      |> Map.new()

    # Save vocab and tag_index
    metadata = %{
      vocab: sanitized_vocab,
      tag_index: tag_index,
      max_sequence_length: @max_sequence_length,
      embedding_dim: @embedding_dim,
      hidden_dim: @hidden_dim
    }
    File.write!(Path.join(path, "metadata.json"), Jason.encode!(metadata))

    Logger.info("Model saved to #{path} (vocab: #{map_size(sanitized_vocab)} words)")
    :ok
  end

  @doc """
  Load a trained model.
  """
  def load_model(path) do
    # Load metadata
    metadata =
      Path.join(path, "metadata.json")
      |> File.read!()
      |> Jason.decode!()

    vocab = metadata["vocab"]
    tag_index = metadata["tag_index"]

    # Rebuild model with same architecture
    model = build_model(
      vocab_size: map_size(vocab),
      num_tags: map_size(tag_index),
      embedding_dim: metadata["embedding_dim"],
      hidden_dim: metadata["hidden_dim"]
    )

    # Load state
    state_binary = File.read!(Path.join(path, "model_state.nx"))
    state = Nx.deserialize(state_binary)

    Logger.info("Model loaded from #{path}")

    {model, state, vocab, tag_index}
  end

  # ---------------------------------------------------------------------------
  # Inference
  # ---------------------------------------------------------------------------

  @doc """
  Simple prediction without serving (for testing).
  Returns top-5 predictions sorted by probability.
  """
  def predict_simple(model, state, text, vocab, tag_index) do
    tokens = tokenize(text)
    encoded = encode_sequence(tokens, vocab)
    input_tensor = Nx.tensor([encoded], type: :s32)

    {_init_fn, predict_fn} = Axon.build(model, compiler: EXLA)
    predictions = predict_fn.(state, %{"input" => input_tensor})

    # Invert tag_index
    index_to_tag = tag_index |> Enum.map(fn {k, v} -> {v, k} end) |> Map.new()

    # Get top 5 predictions by probability (show regardless of threshold)
    predictions
    |> Nx.squeeze()
    |> Nx.to_list()
    |> Enum.with_index()
    |> Enum.sort_by(fn {prob, _idx} -> -prob end)
    |> Enum.take(5)
    |> Enum.map(fn {prob, idx} -> {Map.get(index_to_tag, idx, "unknown"), Float.round(prob, 3)} end)
  end

  @doc """
  Get predictions above threshold for production use.
  """
  def predict_tags(model, state, text, vocab, tag_index, threshold \\ @prediction_threshold) do
    tokens = tokenize(text)
    encoded = encode_sequence(tokens, vocab)
    input_tensor = Nx.tensor([encoded], type: :s32)

    {_init_fn, predict_fn} = Axon.build(model, compiler: EXLA)
    predictions = predict_fn.(state, %{"input" => input_tensor})

    # Invert tag_index
    index_to_tag = tag_index |> Enum.map(fn {k, v} -> {v, k} end) |> Map.new()

    predictions
    |> Nx.squeeze()
    |> Nx.to_list()
    |> Enum.with_index()
    |> Enum.filter(fn {prob, _idx} -> prob > threshold end)
    |> Enum.sort_by(fn {prob, _idx} -> -prob end)
    |> Enum.take(5)
    |> Enum.map(fn {_prob, idx} -> Map.get(index_to_tag, idx, "unknown") end)
  end
end
