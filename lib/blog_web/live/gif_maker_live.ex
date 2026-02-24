defmodule BlogWeb.GifMakerLive do
  use BlogWeb, :live_view

  alias Blog.GifMaker
  alias Blog.GifMaker.{YouTube, Gif, GifGenerator, Captcha, RateLimiter, Processor}

  @impl true
  def mount(params, _session, socket) do
    ip =
      case get_connect_info(socket, :peer_data) do
        %{address: address} -> address |> Tuple.to_list() |> Enum.join(".")
        _ -> "unknown"
      end

    ip_hash = :crypto.hash(:sha256, ip) |> Base.encode16(case: :lower) |> String.slice(0, 16)

    socket =
      socket
      |> assign(
        page_title: "Concert GIF Maker",
        step: :url_input,
        url_input: "",
        video_metadata: nil,
        job: nil,
        start_min: "0",
        start_sec: "0",
        end_min: "0",
        end_sec: "30",
        captcha_question: nil,
        captcha_token: nil,
        captcha_answer: "",
        captcha_error: nil,
        processing_status: nil,
        processing_message: nil,
        frames: [],
        selected_indices: MapSet.new(),
        generated_gif: nil,
        generated_gif_id: nil,
        gif_generating: false,
        error: nil,
        ip_hash: ip_hash,
        loading: false,
        overlay_text: ""
      )

    # Resume existing job from URL params
    socket =
      case params["job"] do
        nil -> socket
        job_id -> resume_job(socket, job_id)
      end

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket =
      case params["job"] do
        nil -> socket
        job_id when socket.assigns.job == nil -> resume_job(socket, job_id)
        _ -> socket
      end

    {:noreply, socket}
  end

  # -- URL Input Step --

  @impl true
  def handle_event("update_url", %{"url" => url}, socket) do
    {:noreply, assign(socket, url_input: url, error: nil)}
  end

  def handle_event("load_video", _params, socket) do
    url = String.trim(socket.assigns.url_input)

    case YouTube.validate_url(url) do
      {:ok, _video_id} ->
        socket = assign(socket, loading: true, error: nil)
        send(self(), {:fetch_metadata, url})
        {:noreply, socket}

      {:error, msg} ->
        {:noreply, assign(socket, error: msg)}
    end
  end

  # -- Time Selection Step --

  def handle_event("update_time", params, socket) do
    socket =
      socket
      |> assign(
        start_min: params["start_min"] || socket.assigns.start_min,
        start_sec: params["start_sec"] || socket.assigns.start_sec,
        end_min: params["end_min"] || socket.assigns.end_min,
        end_sec: params["end_sec"] || socket.assigns.end_sec,
        error: nil
      )

    {:noreply, socket}
  end

  def handle_event("submit_time", _params, socket) do
    %{start_min: sm, start_sec: ss, end_min: em, end_sec: es, video_metadata: meta} = socket.assigns

    start_ms = (parse_int(sm) * 60 + parse_int(ss)) * 1000
    end_ms = (parse_int(em) * 60 + parse_int(es)) * 1000
    duration_sec = meta.duration_seconds

    cond do
      end_ms <= start_ms ->
        {:noreply, assign(socket, error: "End time must be after start time")}

      end_ms - start_ms > 180_000 ->
        {:noreply, assign(socket, error: "Segment cannot exceed 3 minutes")}

      div(end_ms, 1000) > duration_sec ->
        {:noreply, assign(socket, error: "End time exceeds video duration")}

      true ->
        {question, token} = Captcha.generate()

        socket =
          socket
          |> assign(
            step: :captcha,
            start_time_ms: start_ms,
            end_time_ms: end_ms,
            captcha_question: question,
            captcha_token: token,
            captcha_answer: "",
            captcha_error: nil,
            error: nil
          )

        {:noreply, socket}
    end
  end

  # -- CAPTCHA Step --

  def handle_event("update_captcha", %{"answer" => answer}, socket) do
    {:noreply, assign(socket, captcha_answer: answer, captcha_error: nil)}
  end

  def handle_event("submit_captcha", _params, socket) do
    if Captcha.verify(socket.assigns.captcha_answer, socket.assigns.captcha_token) do
      submit_job(socket)
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

  # -- Frame Browse Step --

  def handle_event("toggle_frame", %{"index" => index_str}, socket) do
    index = String.to_integer(index_str)
    selected = socket.assigns.selected_indices

    selected =
      if MapSet.member?(selected, index),
        do: MapSet.delete(selected, index),
        else: MapSet.put(selected, index)

    {:noreply, assign(socket, selected_indices: selected)}
  end

  def handle_event("select_all", _params, socket) do
    all = socket.assigns.frames |> Enum.map(& &1.frame_number) |> MapSet.new()
    {:noreply, assign(socket, selected_indices: all)}
  end

  def handle_event("select_none", _params, socket) do
    {:noreply, assign(socket, selected_indices: MapSet.new())}
  end

  def handle_event("update_overlay_text", %{"text" => text}, socket) do
    {:noreply, assign(socket, overlay_text: String.slice(text, 0, 80))}
  end

  def handle_event("generate_gif", _params, socket) do
    selected = socket.assigns.selected_indices

    if MapSet.size(selected) < 2 do
      {:noreply, assign(socket, error: "Select at least 2 frames")}
    else
      socket = assign(socket, gif_generating: true, error: nil)
      job_id = socket.assigns.job.id
      indices = MapSet.to_list(selected) |> Enum.sort()
      text = String.trim(socket.assigns.overlay_text)

      send(self(), {:generate_gif, job_id, indices, text})
      {:noreply, socket}
    end
  end

  # -- GIF Preview Step --

  def handle_event("try_different", _params, socket) do
    {:noreply, assign(socket, step: :frame_browse, generated_gif: nil, generated_gif_id: nil, gif_generating: false, overlay_text: "")}
  end

  def handle_event("start_over", _params, socket) do
    {:noreply,
     assign(socket,
       step: :url_input,
       url_input: "",
       video_metadata: nil,
       job: nil,
       frames: [],
       selected_indices: MapSet.new(),
       generated_gif: nil,
       generated_gif_id: nil,
       gif_generating: false,
       error: nil,
       overlay_text: ""
     )}
  end

  # -- Async message handlers --

  @impl true
  def handle_info({:fetch_metadata, url}, socket) do
    case YouTube.get_metadata(url) do
      {:ok, meta} ->
        duration = meta.duration_seconds
        default_end_min = min(div(duration, 60), 3) |> Integer.to_string()
        default_end_sec = if duration <= 180, do: Integer.to_string(rem(duration, 60)), else: "0"

        {:noreply,
         assign(socket,
           step: :time_select,
           video_metadata: meta,
           url_input: url,
           end_min: default_end_min,
           end_sec: default_end_sec,
           loading: false,
           error: nil
         )}

      {:error, msg} ->
        {:noreply, assign(socket, error: msg, loading: false)}
    end
  end

  def handle_info({:processing_update, status, message}, socket) do
    socket = assign(socket, processing_status: status, processing_message: message)

    socket =
      case status do
        :ready ->
          frames = GifMaker.list_frames(socket.assigns.job.id)
          all_selected = frames |> Enum.map(& &1.frame_number) |> MapSet.new()
          assign(socket, step: :frame_browse, frames: frames, selected_indices: all_selected)

        :failed ->
          assign(socket, step: :url_input, error: message)

        _ ->
          socket
      end

    {:noreply, socket}
  end

  def handle_info({:generate_gif, job_id, indices, text}, socket) do
    # Include text in hash so different captions = different cached GIFs
    hash = Gif.generate_hash(job_id, indices, text)

    case GifMaker.find_gif_by_hash(hash) do
      %Gif{} = existing ->
        gif_base64 = Base.encode64(existing.gif_data)

        {:noreply,
         assign(socket,
           step: :gif_preview,
           generated_gif: gif_base64,
           generated_gif_id: existing.id,
           gif_generating: false
         )}

      nil ->
        frames = GifMaker.get_frames_by_indices(job_id, indices)
        text_opt = if text == "", do: [], else: [text: text]

        case GifGenerator.generate(frames, text_opt) do
          {:ok, gif_data} ->
            {:ok, saved} =
              GifMaker.save_gif(%{
                job_id: job_id,
                hash: hash,
                frame_indices: indices,
                gif_data: gif_data,
                frame_count: length(indices),
                file_size: byte_size(gif_data)
              })

            gif_base64 = Base.encode64(gif_data)

            {:noreply,
             assign(socket,
               step: :gif_preview,
               generated_gif: gif_base64,
               generated_gif_id: saved.id,
               gif_generating: false
             )}

          {:error, reason} ->
            {:noreply, assign(socket, error: to_string(reason), gif_generating: false)}
        end
    end
  end

  # -- Helpers --

  defp submit_job(socket) do
    %{ip_hash: ip_hash, video_metadata: meta, url_input: url} = socket.assigns

    case RateLimiter.check(ip_hash) do
      {:error, msg} ->
        {:noreply, assign(socket, error: msg)}

      :ok ->
        RateLimiter.record(ip_hash)

        {:ok, _video_id} = YouTube.validate_url(url)

        attrs = %{
          youtube_url: url,
          video_id: meta.video_id,
          title: meta.title,
          duration_seconds: meta.duration_seconds,
          start_time_ms: socket.assigns.start_time_ms,
          end_time_ms: socket.assigns.end_time_ms,
          ip_hash: ip_hash
        }

        case GifMaker.create_job(attrs) do
          {:ok, job} ->
            Phoenix.PubSub.subscribe(Blog.PubSub, "gif_maker:#{job.id}")
            Processor.process_job(job.id)

            {:noreply,
             assign(socket,
               step: :processing,
               job: job,
               processing_status: :pending,
               processing_message: "Queued for processing...",
               error: nil
             )
             |> push_patch(to: ~p"/gif-maker?job=#{job.id}")}

          {:error, changeset} ->
            errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _} -> msg end)
            {:noreply, assign(socket, error: inspect(errors))}
        end
    end
  end

  defp resume_job(socket, job_id) do
    case GifMaker.get_job(job_id) do
      nil ->
        socket

      job ->
        Phoenix.PubSub.subscribe(Blog.PubSub, "gif_maker:#{job.id}")

        case job.status do
          "ready" ->
            frames = GifMaker.list_frames(job.id)
            all_selected = frames |> Enum.map(& &1.frame_number) |> MapSet.new()

            assign(socket,
              step: :frame_browse,
              job: job,
              video_metadata: %{video_id: job.video_id, title: job.title, duration_seconds: job.duration_seconds},
              frames: frames,
              selected_indices: all_selected
            )

          status when status in ["pending", "downloading", "extracting"] ->
            assign(socket,
              step: :processing,
              job: job,
              video_metadata: %{video_id: job.video_id, title: job.title, duration_seconds: job.duration_seconds},
              processing_status: String.to_atom(status),
              processing_message: "Processing..."
            )

          _ ->
            socket
        end
    end
  end

  defp parse_int(str) do
    case Integer.parse(to_string(str)) do
      {n, _} -> max(n, 0)
      :error -> 0
    end
  end

  defp format_duration(nil), do: "?"
  defp format_duration(seconds) do
    m = div(seconds, 60)
    s = rem(seconds, 60)
    "#{m}:#{String.pad_leading(Integer.to_string(s), 2, "0")}"
  end

  defp step_number(:url_input), do: 1
  defp step_number(:time_select), do: 2
  defp step_number(:captcha), do: 3
  defp step_number(:processing), do: 4
  defp step_number(:frame_browse), do: 5
  defp step_number(:gif_preview), do: 6

  defp step_label(:url_input), do: "Paste URL"
  defp step_label(:time_select), do: "Select Time"
  defp step_label(:captcha), do: "Verify"
  defp step_label(:processing), do: "Processing"
  defp step_label(:frame_browse), do: "Pick Frames"
  defp step_label(:gif_preview), do: "Your GIF"

  defp progress_pct(:pending), do: 10
  defp progress_pct(:downloading), do: 40
  defp progress_pct(:extracting), do: 70
  defp progress_pct(:ready), do: 100
  defp progress_pct(:failed), do: 0
  defp progress_pct(_), do: 5
end
