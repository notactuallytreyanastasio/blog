defmodule Blog.Push.WebPushTest do
  use ExUnit.Case, async: true

  alias Blog.Push.WebPush

  defp b64(s), do: Base.url_decode64!(s, padding: false)

  # RFC 8291 Appendix A: the full worked example, byte for byte.
  test "encrypts exactly like the RFC 8291 example" do
    sub = %{
      endpoint: "https://push.example.net/send/abc",
      p256dh: "BCVxsr7N_eNgVRqvHtD0zTZsEc6-VV-JvLexhqUzORcxaOzi6-AYWXvTBHm4bjyPjs7Vd8pZGH6SRpkNtoIAiw4",
      auth: "BTBZMqHH6r4Tts7J_aSIgg"
    }

    {:ok, body} =
      WebPush.encrypt("When I grow up, I want to be a watermelon", sub,
        salt: b64("DGv6ra1nlYgDCS1FRnbzlw"),
        as_public: b64("BP4z9KsN6nGRTbVYI_c7VJSPQTBtkgcy27mlmlMoZIIgDll6e3vCYLocInmYWAmS6TlzAC8wEqKK6PBru3jl7A8"),
        as_private: b64("yfWPiYE-n46HLnH0KqZOF1fJJU3MYrct3AELtAQ-oRw")
      )

    expected =
      "DGv6ra1nlYgDCS1FRnbzlwAAEABBBP4z9KsN6nGRTbVYI_c7VJSPQTBtkgcy27mlmlMoZIIgDll6e3vCYLocInmYWAmS6TlzAC8wEqKK6PBru3jl7A_yl95bQpu6cVPTpK4Mqgkf1CXztLVBSt2Ks3oZwbuwXPXLWyouBWLVWGNWQexSgSxsj_Qulcy4a-fN"

    assert Base.url_encode64(body, padding: false) == expected
  end

  test "a browser can decrypt what we encrypt with random keys" do
    {ua_public, ua_private} = :crypto.generate_key(:ecdh, :secp256r1)
    auth = :crypto.strong_rand_bytes(16)

    sub = %{
      endpoint: "https://web.push.apple.com/x",
      p256dh: Base.url_encode64(ua_public, padding: false),
      auth: Base.url_encode64(auth, padding: false)
    }

    {:ok, body} = WebPush.encrypt(~s({"title":"hi"}), sub)

    <<salt::binary-16, 4096::32, 65, as_public::binary-65, rest::binary>> = body
    ct_len = byte_size(rest) - 16
    <<ciphertext::binary-size(ct_len), tag::binary-16>> = rest

    shared = :crypto.compute_key(:ecdh, as_public, ua_private, :secp256r1)

    hkdf = fn s, ikm, info, n ->
      binary_part(:crypto.mac(:hmac, :sha256, :crypto.mac(:hmac, :sha256, s, ikm), info <> <<1>>), 0, n)
    end

    ikm = hkdf.(auth, shared, "WebPush: info" <> <<0>> <> ua_public <> as_public, 32)
    cek = hkdf.(salt, ikm, "Content-Encoding: aes128gcm" <> <<0>>, 16)
    nonce = hkdf.(salt, ikm, "Content-Encoding: nonce" <> <<0>>, 12)

    assert :crypto.crypto_one_time_aead(:aes_128_gcm, cek, nonce, ciphertext, <<>>, tag, false) ==
             ~s({"title":"hi"}) <> <<2>>
  end

  test "rejects malformed subscription keys" do
    assert {:error, _} = WebPush.encrypt("x", %{endpoint: "https://x", p256dh: "nope", auth: "nope"})
  end

  test "generates usable vapid keys" do
    %{public_key: pub, private_key: priv} = WebPush.generate_vapid_keys()
    assert byte_size(b64(pub)) == 65
    assert byte_size(b64(priv)) == 32
  end
end
