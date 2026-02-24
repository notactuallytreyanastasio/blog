defmodule Blog.GifMaker.Captcha do
  @secret_salt "gif_maker_captcha_v1"
  @max_age_seconds 300

  def generate do
    a = Enum.random(2..15)
    b = Enum.random(2..15)
    op = Enum.random([:add, :subtract, :multiply])

    {question, answer} =
      case op do
        :add -> {"#{a} + #{b}", a + b}
        :subtract -> {"#{max(a, b)} - #{min(a, b)}", abs(a - b)}
        :multiply -> {"#{a} x #{b}", a * b}
      end

    token = Phoenix.Token.sign(BlogWeb.Endpoint, @secret_salt, answer)
    {question, token}
  end

  def verify(user_answer, token) do
    with {answer_int, _} <- Integer.parse(to_string(user_answer)),
         {:ok, expected} <- Phoenix.Token.verify(BlogWeb.Endpoint, @secret_salt, token, max_age: @max_age_seconds) do
      answer_int == expected
    else
      _ -> false
    end
  end
end
