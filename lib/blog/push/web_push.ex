defmodule Blog.Push.WebPush do
  @moduledoc """
  Web Push for the pinnable blinks PWA: RFC 8291 message encryption
  (`aes128gcm`) plus RFC 8292 VAPID authorization, sent straight to the
  browser vendor's push service (Apple's for iOS Safari home-screen apps).

  Written against the RFCs rather than a library because Apple's service only
  accepts the final `aes128gcm` content coding, and the available Elixir
  packages still emit the older draft `aesgcm`. `encrypt/3` is deterministic
  when given a salt and ephemeral key, which is how the test pins it to the
  RFC 8291 Appendix A vector.
  """

  require Logger

  @curve :secp256r1
  @record_size 4096

  @type subscription :: %{
          endpoint: String.t(),
          p256dh: String.t(),
          auth: String.t()
        }

  @spec configured?() :: boolean()
  def configured?, do: Application.get_env(:blog, :web_push) != nil

  @spec public_key() :: String.t() | nil
  def public_key, do: config(:public_key)

  defp config(key) do
    case Application.get_env(:blog, :web_push) do
      nil -> nil
      cfg -> Keyword.get(cfg, key)
    end
  end

  @doc """
  Push a JSON payload to one subscription. Returns `:ok`, `{:error, :expired}`
  when the push service says the subscription is gone (404/410), or
  `{:error, term}` for anything else.
  """
  @spec send(subscription() | struct(), map(), keyword()) :: :ok | {:error, term()}
  def send(sub, payload, opts \\ []) when is_map(payload) do
    with true <- configured?() || {:error, :not_configured},
         {:ok, body} <- encrypt(Jason.encode!(payload), sub) do
      headers = [
        {"content-encoding", "aes128gcm"},
        {"content-type", "application/octet-stream"},
        {"ttl", to_string(Keyword.get(opts, :ttl, 3600))},
        {"urgency", Keyword.get(opts, :urgency, "normal")},
        {"authorization", vapid_authorization(sub.endpoint)}
      ]

      case Req.post(sub.endpoint, body: body, headers: headers, retry: false, receive_timeout: 15_000) do
        {:ok, %{status: s}} when s in 200..202 -> :ok
        {:ok, %{status: s}} when s in [404, 410] -> {:error, :expired}
        {:ok, %{status: s, body: b}} -> {:error, {:http, s, to_string(inspect(b))}}
        {:error, reason} -> {:error, reason}
      end
    end
  end

  # ---------------------------------------------------------------------------
  # RFC 8291 encryption
  # ---------------------------------------------------------------------------

  @doc """
  Encrypt `plaintext` for a subscription. Options `:salt` (16 bytes) and
  `:as_private`/`:as_public` (the sender's ephemeral P-256 key pair) exist for
  tests; normally both are random per message.
  """
  @spec encrypt(binary(), subscription() | struct(), keyword()) :: {:ok, binary()} | {:error, term()}
  def encrypt(plaintext, sub, opts \\ []) do
    with {:ok, ua_public} <- b64url_decode(sub.p256dh),
         {:ok, auth_secret} <- b64url_decode(sub.auth),
         true <- byte_size(ua_public) == 65 || {:error, :bad_p256dh},
         true <- byte_size(auth_secret) == 16 || {:error, :bad_auth} do
      salt = Keyword.get_lazy(opts, :salt, fn -> :crypto.strong_rand_bytes(16) end)

      {as_public, as_private} =
        case Keyword.fetch(opts, :as_private) do
          {:ok, priv} -> {Keyword.fetch!(opts, :as_public), priv}
          :error -> :crypto.generate_key(:ecdh, @curve)
        end

      shared = :crypto.compute_key(:ecdh, ua_public, as_private, @curve)

      # IKM = HKDF(auth_secret, ecdh_secret, "WebPush: info" || 0x00 || ua_public || as_public, 32)
      ikm = hkdf(auth_secret, shared, "WebPush: info" <> <<0>> <> ua_public <> as_public, 32)
      cek = hkdf(salt, ikm, "Content-Encoding: aes128gcm" <> <<0>>, 16)
      nonce = hkdf(salt, ikm, "Content-Encoding: nonce" <> <<0>>, 12)

      # one record: plaintext, then the 0x02 "last record" delimiter
      record = plaintext <> <<2>>
      {ciphertext, tag} = :crypto.crypto_one_time_aead(:aes_128_gcm, cek, nonce, record, <<>>, 16, true)

      header = salt <> <<@record_size::32>> <> <<byte_size(as_public)>> <> as_public
      {:ok, header <> ciphertext <> tag}
    end
  end

  # HKDF-SHA256 (RFC 5869) for the short outputs Web Push needs (<= 32 bytes).
  defp hkdf(salt, ikm, info, length) do
    prk = :crypto.mac(:hmac, :sha256, salt, ikm)
    binary_part(:crypto.mac(:hmac, :sha256, prk, info <> <<1>>), 0, length)
  end

  # ---------------------------------------------------------------------------
  # RFC 8292 VAPID
  # ---------------------------------------------------------------------------

  defp vapid_authorization(endpoint) do
    %URI{scheme: scheme, host: host, port: port} = URI.parse(endpoint)
    default_port = if scheme == "https", do: 443, else: 80
    aud = if port in [nil, default_port], do: "#{scheme}://#{host}", else: "#{scheme}://#{host}:#{port}"

    claims = %{
      "aud" => aud,
      # Apple rejects anything beyond 24h; 12h is plenty for a one-shot push
      "exp" => System.system_time(:second) + 12 * 3600,
      "sub" => config(:subject) || "https://bobbby.online"
    }

    {_, jwt} = JOSE.JWT.sign(vapid_jwk(), %{"alg" => "ES256"}, claims) |> JOSE.JWS.compact()
    "vapid t=#{jwt}, k=#{config(:public_key)}"
  end

  # Keys are stored as base64url: 65-byte uncompressed public point, 32-byte scalar.
  defp vapid_jwk do
    {:ok, <<4, x::binary-32, y::binary-32>>} = b64url_decode(config(:public_key))
    {:ok, d} = b64url_decode(config(:private_key))

    JOSE.JWK.from_map(%{
      "kty" => "EC",
      "crv" => "P-256",
      "x" => Base.url_encode64(x, padding: false),
      "y" => Base.url_encode64(y, padding: false),
      "d" => Base.url_encode64(d, padding: false)
    })
  end

  @doc "Generate a fresh VAPID key pair as base64url strings."
  @spec generate_vapid_keys() :: %{public_key: String.t(), private_key: String.t()}
  def generate_vapid_keys do
    {pub, priv} = :crypto.generate_key(:ecdh, @curve)

    %{
      public_key: Base.url_encode64(pub, padding: false),
      private_key: Base.url_encode64(priv, padding: false)
    }
  end

  defp b64url_decode(nil), do: {:error, :missing}

  defp b64url_decode(s) when is_binary(s) do
    s = String.replace(s, ~r/[=\s]/, "")

    case Base.url_decode64(s, padding: false) do
      {:ok, bin} -> {:ok, bin}
      :error -> with({:ok, bin} <- Base.decode64(s, padding: false), do: {:ok, bin}, else: (_ -> {:error, :bad_base64}))
    end
  end
end
