defmodule BlogWeb.CollageMakerLive do
  use BlogWeb, :live_view

  alias Blog.CollageMaker
  alias Blog.CollageMaker.{Collage, RateLimiter}
  alias Blog.GifMaker.Captcha

  @max_images 36
  @max_file_size 20_000_000

  @impl true
  def mount(_params, _session, socket) do
    ip =
      case get_connect_info(socket, :peer_data) do
        %{address: address} -> address |> Tuple.to_list() |> Enum.join(".")
        _ -> "unknown"
      end

    ip_hash = :crypto.hash(:sha256, ip) |> Base.encode16(case: :lower) |> String.slice(0, 16)

    socket =
      socket
      |> assign(
        page_title: "Collage Maker",
        step: :upload,
        columns: 4,
        collage: nil,
        processing_status: nil,
        processing_message: nil,
        error: nil,
        ip_hash: ip_hash,
        captcha_question: nil,
        captcha_token: nil,
        captcha_answer: "",
        captcha_error: nil,
        share_url: nil,
        shuffled_order: nil,
        shuffle_count: 0,
        result_images: []
      )
      |> allow_upload(:images,
        accept: ~w(.jpg .jpeg .png .webp),
        max_entries: @max_images,
        max_file_size: @max_file_size,
        chunk_size: 512_000
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_uploads", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("remove_image", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :images, ref)}
  end

  def handle_event("next_configure", _params, socket) do
    entries = socket.assigns.uploads.images.entries

    if length(entries) < 2 do
      {:noreply, assign(socket, error: "Upload at least 2 images.")}
    else
      count = length(entries)
      columns = suggest_columns(count)
      {:noreply, assign(socket, step: :configure, columns: columns, error: nil)}
    end
  end

  def handle_event("set_columns", %{"columns" => cols_str}, socket) do
    columns = String.to_integer(cols_str)
    {:noreply, assign(socket, columns: columns)}
  end

  def handle_event("randomize", _params, socket) do
    entries = socket.assigns.uploads.images.entries
    shuffled_order = Enum.shuffle(0..(length(entries) - 1))
    shuffle_count = (socket.assigns[:shuffle_count] || 0) + 1
    {:noreply, assign(socket, shuffled_order: shuffled_order, shuffle_count: shuffle_count)}
  end

  def handle_event("next_captcha", _params, socket) do
    {question, token} = Captcha.generate()

    {:noreply,
     assign(socket,
       step: :captcha,
       captcha_question: question,
       captcha_token: token,
       captcha_answer: "",
       captcha_error: nil
     )}
  end

  def handle_event("update_captcha", params, socket) do
    answer = params["answer"] || ""
    socket = assign(socket, captcha_answer: answer)
    {:noreply, socket}
  end


  def handle_event("verify_captcha", %{"answer" => answer}, socket) do
    if Captcha.verify(answer, socket.assigns.captcha_token) do
      case RateLimiter.check(socket.assigns.ip_hash) do
        :ok ->
          # MUST consume uploads inside handle_event (LiveView requirement)
          uploaded =
            consume_uploaded_entries(socket, :images, fn %{path: path}, entry ->
              image_binary = File.read!(path)

              content_type =
                case Path.extname(entry.client_name) |> String.downcase() do
                  ".png" -> "image/png"
                  ".webp" -> "image/webp"
                  _ -> "image/jpeg"
                end

              {:ok, {image_binary, content_type, entry.client_name}}
            end)

          send(self(), {:start_processing, uploaded})
          {:noreply, assign(socket, step: :processing, processing_message: "Starting...", error: nil)}

        {:error, msg} ->
          {:noreply, assign(socket, captcha_error: msg)}
      end
    else
      {question, token} = Captcha.generate()

      {:noreply,
       assign(socket,
         captcha_error: "Wrong answer. Try again.",
         captcha_question: question,
         captcha_token: token,
         captcha_answer: ""
       )}
    end
  end

  def handle_event("back_to_upload", _params, socket) do
    {:noreply, assign(socket, step: :upload, error: nil)}
  end

  def handle_event("back_to_configure", _params, socket) do
    {:noreply, assign(socket, step: :configure, captcha_error: nil)}
  end

  def handle_event("start_over", _params, socket) do
    {:noreply,
     socket
     |> assign(
       step: :upload,
       collage: nil,
       error: nil,
       processing_status: nil,
       processing_message: nil,
       share_url: nil
     )
     |> allow_upload(:images,
       accept: ~w(.jpg .jpeg .png .webp),
       max_entries: @max_images,
       max_file_size: @max_file_size,
       chunk_size: 512_000
     )}
  end

  @impl true
  def handle_info({:start_processing, uploaded}, socket) do
    share_token = Collage.generate_share_token()
    expires_at = DateTime.add(DateTime.utc_now(), 24 * 3600, :second)

    {:ok, collage} =
      CollageMaker.create_collage(%{
        status: "uploading",
        columns: socket.assigns.columns,
        ip_hash: socket.assigns.ip_hash,
        share_token: share_token,
        expires_at: expires_at
      })

    Phoenix.PubSub.subscribe(Blog.PubSub, "collage_maker:#{collage.id}")
    RateLimiter.record(socket.assigns.ip_hash)

    shuffled_order = socket.assigns.shuffled_order || Enum.to_list(0..(length(uploaded) - 1))

    # Upload originals to S3
    uploaded
    |> Enum.with_index()
    |> Enum.each(fn {{binary, content_type, _filename}, idx} ->
      position = Enum.at(shuffled_order, idx, idx)
      ext = if content_type == "image/png", do: ".png", else: ".jpg"
      s3_key = "collage-maker/#{collage.id}/original/#{position}#{ext}"

      {:ok, _} = Blog.Storage.upload(s3_key, binary, content_type: content_type)

      {:ok, _} =
        CollageMaker.add_image(%{
          collage_id: collage.id,
          position: position,
          original_s3_key: s3_key,
          content_type: content_type,
          file_size: byte_size(binary)
        })
    end)

    Blog.CollageMaker.Processor.process_collage(collage.id)

    share_url = url(~p"/collage/#{share_token}")

    {:noreply, assign(socket, collage: collage, share_url: share_url, processing_message: "Uploading images...")}
  end

  def handle_info({:processing_update, status, message}, socket) do
    socket = assign(socket, processing_status: status, processing_message: message)

    socket =
      case status do
        :ready ->
          collage = CollageMaker.get_collage!(socket.assigns.collage.id)
          images = CollageMaker.list_images(collage.id)
          assign(socket, step: :result, collage: collage, result_images: images)

        :failed ->
          assign(socket, step: :result, error: message)

        _ ->
          socket
      end

    {:noreply, socket}
  end

  defp error_to_string(:too_large), do: "File too large (max 20MB)"
  defp error_to_string(:too_many_files), do: "Too many files (max 50)"
  defp error_to_string(:not_accepted), do: "Invalid file type"
  defp error_to_string(err), do: inspect(err)

  defp suggest_columns(count) do
    cond do
      count <= 4 -> count
      count <= 9 -> 3
      count <= 16 -> 4
      count <= 30 -> 5
      true -> 6
    end
  end
end
