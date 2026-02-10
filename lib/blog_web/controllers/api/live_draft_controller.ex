defmodule BlogWeb.Api.LiveDraftController do
  use BlogWeb, :controller

  def update(conn, %{"slug" => slug, "content" => content} = params) do
    auth_token = params["auth_token"] || get_req_header(conn, "x-auth-token") |> List.first()

    if authorized?(auth_token) do
      {:ok, _html} = Blog.LiveDraft.update(slug, content)
      json(conn, %{status: "ok", slug: slug})
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Invalid or missing auth token"})
    end
  end

  defp authorized?(token) do
    expected_token = Application.get_env(:blog, :live_draft_api_token)
    token == expected_token && token != nil
  end
end
