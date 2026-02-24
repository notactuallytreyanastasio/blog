defmodule Blog.Storage do
  @moduledoc """
  S3-compatible object storage via Hetzner Object Storage.
  """

  def bucket do
    Application.get_env(:blog, :s3_bucket, "bobbby-media")
  end

  def create_bucket do
    ExAws.S3.put_bucket(bucket(), "fsn1")
    |> ExAws.request()
  end

  def upload(key, data, opts \\ []) do
    content_type = Keyword.get(opts, :content_type, "application/octet-stream")
    acl = Keyword.get(opts, :acl, :public_read)

    ExAws.S3.put_object(bucket(), key, data,
      content_type: content_type,
      acl: acl
    )
    |> ExAws.request()
  end

  def delete(key) do
    ExAws.S3.delete_object(bucket(), key)
    |> ExAws.request()
  end

  def url(key) do
    "https://#{bucket()}.fsn1.your-objectstorage.com/#{key}"
  end

  def list(prefix \\ "") do
    ExAws.S3.list_objects(bucket(), prefix: prefix)
    |> ExAws.request()
  end
end
