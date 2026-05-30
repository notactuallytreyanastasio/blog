defmodule Blog.Storage do
  @moduledoc """
  S3-compatible object storage via Hetzner Object Storage.
  """

  @spec bucket() :: String.t()
  def bucket do
    Application.get_env(:blog, :s3_bucket, "bobbby-media")
  end

  @spec create_bucket() :: {:ok, term()} | {:error, term()}
  def create_bucket do
    ExAws.S3.put_bucket(bucket(), "fsn1")
    |> ExAws.request()
  end

  @spec upload(String.t(), binary(), keyword()) :: {:ok, term()} | {:error, term()}
  def upload(key, data, opts \\ []) do
    content_type = Keyword.get(opts, :content_type, "application/octet-stream")
    acl = Keyword.get(opts, :acl, :public_read)

    ExAws.S3.put_object(bucket(), key, data,
      content_type: content_type,
      acl: acl
    )
    |> ExAws.request()
  end

  @spec delete(String.t()) :: {:ok, term()} | {:error, term()}
  def delete(key) do
    ExAws.S3.delete_object(bucket(), key)
    |> ExAws.request()
  end

  @spec url(String.t()) :: String.t()
  def url(key) do
    "https://#{bucket()}.fsn1.your-objectstorage.com/#{key}"
  end

  @spec list(String.t()) :: {:ok, term()} | {:error, term()}
  def list(prefix \\ "") do
    ExAws.S3.list_objects(bucket(), prefix: prefix)
    |> ExAws.request()
  end
end
