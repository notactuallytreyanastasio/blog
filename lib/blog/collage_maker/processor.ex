defmodule Blog.CollageMaker.Processor do
  use GenServer
  require Logger

  alias Blog.CollageMaker
  alias Blog.CollageMaker.ImageProcessor

  @max_concurrent 2

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{active: 0}, name: __MODULE__)
  end

  def process_collage(collage_id) do
    GenServer.cast(__MODULE__, {:process, collage_id})
  end

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_cast({:process, collage_id}, %{active: active} = state) when active >= @max_concurrent do
    Logger.warning("Collage Maker: max concurrent jobs reached, queueing #{collage_id}")
    Process.send_after(self(), {:retry, collage_id}, 5_000)
    {:noreply, state}
  end

  def handle_cast({:process, collage_id}, %{active: active} = state) do
    Task.Supervisor.async_nolink(Blog.CollageMaker.TaskSupervisor, fn ->
      run_pipeline(collage_id)
    end)

    {:noreply, %{state | active: active + 1}}
  end

  @impl true
  def handle_info({:retry, collage_id}, state) do
    handle_cast({:process, collage_id}, state)
    {:noreply, state}
  end

  def handle_info({ref, _result}, %{active: active} = state) when is_reference(ref) do
    Process.demonitor(ref, [:flush])
    {:noreply, %{state | active: max(active - 1, 0)}}
  end

  def handle_info({:DOWN, _ref, :process, _pid, reason}, %{active: active} = state) do
    if reason != :normal do
      Logger.error("Collage Maker task crashed: #{inspect(reason)}")
    end

    {:noreply, %{state | active: max(active - 1, 0)}}
  end

  defp run_pipeline(collage_id) do
    collage = CollageMaker.get_collage!(collage_id)
    images = CollageMaker.list_images(collage_id)
    tmp_dir = Path.join(System.tmp_dir!(), "collage_#{collage_id}_#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp_dir)

    try do
      broadcast(collage_id, :processing, "Downloading images...")
      CollageMaker.update_collage(collage, %{status: "processing"})

      # Download originals from S3 to temp dir and get dimensions
      broadcast(collage_id, :processing, "Analyzing images...")
      images_with_dims = download_and_measure(images, tmp_dir, collage_id)

      # Update image dimensions in DB
      Enum.each(images_with_dims, fn {img, w, h} ->
        CollageMaker.update_image(img, %{original_width: w, original_height: h})
      end)

      # Compute cell size
      cell_size = ImageProcessor.compute_cell_size(
        Enum.map(images_with_dims, fn {_img, w, h} ->
          %{original_width: w, original_height: h}
        end)
      )

      CollageMaker.update_collage(collage, %{cell_size: cell_size})

      # Crop each image to square
      broadcast(collage_id, :processing, "Cropping images to square...")
      cropped_paths = crop_images(images_with_dims, cell_size, tmp_dir, collage_id)

      # Upload cropped versions to S3
      broadcast(collage_id, :processing, "Uploading cropped images...")
      upload_cropped(images, cropped_paths, collage_id)

      # Stitch collage
      broadcast(collage_id, :processing, "Stitching collage...")
      collage_path = Path.join(tmp_dir, "collage.jpg")

      case ImageProcessor.stitch_collage(cropped_paths, collage.columns, cell_size, collage_path) do
        {:ok, _, canvas_w, canvas_h} ->
          # Upload collage to S3
          broadcast(collage_id, :processing, "Uploading collage...")
          collage_data = File.read!(collage_path)
          collage_s3_key = "collage-maker/#{collage_id}/collage.jpg"

          case Blog.Storage.upload(collage_s3_key, collage_data, content_type: "image/jpeg") do
            {:ok, _} ->
              CollageMaker.update_collage(collage, %{
                status: "ready",
                collage_s3_key: collage_s3_key,
                collage_width: canvas_w,
                collage_height: canvas_h,
                collage_file_size: byte_size(collage_data),
                image_count: length(images)
              })

              broadcast(collage_id, :ready, "Collage ready!")
              Logger.info("Collage Maker #{collage_id}: ready (#{canvas_w}x#{canvas_h})")

            {:error, reason} ->
              fail(collage, collage_id, "S3 upload failed: #{inspect(reason)}")
          end

        {:error, reason} ->
          fail(collage, collage_id, reason)
      end
    rescue
      e ->
        fail(collage, collage_id, Exception.message(e))
    after
      File.rm_rf(tmp_dir)
    end
  end

  defp download_and_measure(images, tmp_dir, collage_id) do
    images
    |> Enum.with_index()
    |> Enum.map(fn {img, idx} ->
      broadcast(collage_id, :processing, "Downloading image #{idx + 1}/#{length(images)}...")
      ext = Path.extname(img.original_s3_key) |> String.downcase()
      local_path = Path.join(tmp_dir, "original_#{img.position}#{ext}")

      # Download from S3
      {:ok, %{body: body}} =
        ExAws.S3.get_object(Blog.Storage.bucket(), img.original_s3_key)
        |> ExAws.request()

      File.write!(local_path, body)

      {:ok, w, h} = ImageProcessor.get_dimensions(local_path)
      {img, w, h}
    end)
  end

  defp crop_images(images_with_dims, cell_size, tmp_dir, collage_id) do
    total = length(images_with_dims)

    images_with_dims
    |> Enum.with_index()
    |> Enum.map(fn {{img, _w, _h}, idx} ->
      broadcast(collage_id, :processing, "Cropping image #{idx + 1}/#{total}...")
      ext = Path.extname(img.original_s3_key) |> String.downcase()
      input_path = Path.join(tmp_dir, "original_#{img.position}#{ext}")
      output_path = Path.join(tmp_dir, "cropped_#{img.position}.jpg")

      {:ok, _} = ImageProcessor.square_crop(input_path, output_path, cell_size)
      output_path
    end)
  end

  defp upload_cropped(images, cropped_paths, collage_id) do
    Enum.zip(images, cropped_paths)
    |> Enum.each(fn {img, cropped_path} ->
      data = File.read!(cropped_path)
      s3_key = "collage-maker/#{collage_id}/cropped/#{img.position}.jpg"

      {:ok, _} = Blog.Storage.upload(s3_key, data, content_type: "image/jpeg")

      CollageMaker.update_image(img, %{cropped_s3_key: s3_key})
    end)
  end

  defp fail(collage, collage_id, reason) do
    CollageMaker.update_collage(collage, %{status: "failed", error_message: to_string(reason)})
    broadcast(collage_id, :failed, to_string(reason))
    Logger.error("Collage Maker #{collage_id} failed: #{reason}")
  end

  defp broadcast(collage_id, status, message) do
    Phoenix.PubSub.broadcast(Blog.PubSub, "collage_maker:#{collage_id}", {:processing_update, status, message})
  end
end
