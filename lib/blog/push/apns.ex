defmodule Blog.Push.APNS do
  @moduledoc """
  Minimal APNs client: HTTP/2 over Finch with token-based (.p8) auth, no
  push-library dependency. Config lives under `config :blog, :apns` —
  `key` (PEM contents of the AuthKey_XXX.p8), `key_id`, `team_id`, `topic`
  (the app's bundle id). Absent config disables pushes entirely.

  Auth JWTs are cached ~40 minutes (Apple wants refresh between 20 and 60).
  """
  use Agent

  require Logger

  @prod_host "https://api.push.apple.com"
  @dev_host "https://api.sandbox.push.apple.com"
  @jwt_ttl_seconds 2400

  @spec start_link(term()) :: Agent.on_start()
  def start_link(_opts), do: Agent.start_link(fn -> %{} end, name: __MODULE__)

  @spec configured?() :: boolean()
  def configured?, do: Application.get_env(:blog, :apns) != nil

  @doc """
  Sends one alert push. `env` is "dev" (sandbox) or "prod". Returns `:ok`,
  `{:error, status, body}` for an APNs rejection, or `{:error, :transport, msg}`.
  """
  @spec push(String.t(), String.t(), map()) ::
          :ok | {:error, non_neg_integer(), binary()} | {:error, :transport, String.t()}
  def push(device_token, env, payload) do
    cfg = Application.fetch_env!(:blog, :apns)
    host = if env == "dev", do: @dev_host, else: @prod_host

    req =
      Finch.build(
        :post,
        host <> "/3/device/" <> device_token,
        [
          {"authorization", "bearer " <> jwt(cfg)},
          {"apns-topic", cfg[:topic]},
          {"apns-push-type", "alert"},
          {"apns-priority", "10"},
          {"content-type", "application/json"}
        ],
        Jason.encode!(payload)
      )

    case Finch.request(req, Blog.Push.Finch) do
      {:ok, %Finch.Response{status: 200}} -> :ok
      {:ok, %Finch.Response{status: status, body: body}} -> {:error, status, body}
      {:error, err} -> {:error, :transport, Exception.message(err)}
    end
  end

  # ── ES256 JWT ─────────────────────────────────────────────────────────────

  defp jwt(cfg) do
    Agent.get_and_update(__MODULE__, fn state ->
      now = System.system_time(:second)

      case state do
        %{jwt: jwt, issued_at: at} when now - at < @jwt_ttl_seconds ->
          {jwt, state}

        _ ->
          jwt = sign_jwt(cfg, now)
          {jwt, %{jwt: jwt, issued_at: now}}
      end
    end)
  end

  defp sign_jwt(cfg, now) do
    header = b64(Jason.encode!(%{"alg" => "ES256", "kid" => cfg[:key_id]}))
    claims = b64(Jason.encode!(%{"iss" => cfg[:team_id], "iat" => now}))
    signing_input = header <> "." <> claims
    der = :public_key.sign(signing_input, :sha256, decode_p8(cfg[:key]))
    signing_input <> "." <> b64(der_to_raw(der))
  end

  # .p8 files are PKCS#8 ("BEGIN PRIVATE KEY"); pem_entry_decode unwraps to
  # an ECPrivateKey record on OTP 21+.
  defp decode_p8(pem) do
    [entry] = :public_key.pem_decode(pem)
    :public_key.pem_entry_decode(entry)
  end

  # :public_key.sign returns a DER ECDSA-Sig-Value; JOSE wants raw r||s.
  defp der_to_raw(der) do
    {:"ECDSA-Sig-Value", r, s} = :public_key.der_decode(:"ECDSA-Sig-Value", der)
    <<r::unsigned-big-integer-size(256), s::unsigned-big-integer-size(256)>>
  end

  defp b64(bin), do: Base.url_encode64(bin, padding: false)
end
