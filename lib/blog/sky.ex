defmodule Blog.Sky do
  @moduledoc """
  Context for Fill The Sky community map data.
  """

  import Ecto.Query
  alias Blog.Repo
  alias Blog.Sky.Profile

  @spec get_profile_by_handle(String.t()) :: {:ok, Profile.t()} | {:error, :not_found}
  def get_profile_by_handle(handle) do
    case Repo.one(from p in Profile, where: p.handle == ^handle, limit: 1) do
      nil -> {:error, :not_found}
      profile -> {:ok, profile}
    end
  end
end
