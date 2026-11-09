defmodule Blog.Pinball.Score do
  @moduledoc """
  One cash-out from Spin Spin Spin: three initials, the credits banked,
  the stage reached, the line mode, and the badges the player owned.
  """
  use Ecto.Schema
  import Ecto.Changeset

  # The badge ids the game's shop sells (spin_glue.mjs, BADGES).
  @badges ~w(cherry lemon bell bar seven star crown diamond)
  @max_score 50_000

  schema "pinball_scores" do
    field :initials, :string
    field :score, :integer
    field :stage, :integer
    field :lines, :integer
    field :badges, {:array, :string}, default: []
    timestamps(updated_at: false)
  end

  def badges, do: @badges
  def max_score, do: @max_score

  def changeset(score, attrs) do
    score
    |> cast(attrs, [:initials, :score, :stage, :lines, :badges])
    |> update_change(:initials, &(&1 |> String.trim() |> String.upcase()))
    |> validate_required([:initials, :score, :stage, :lines])
    |> validate_format(:initials, ~r/\A[A-Z]{3}\z/, message: "must be three letters, A to Z")
    |> validate_number(:score, greater_than: 0, less_than_or_equal_to: @max_score)
    |> validate_number(:stage, greater_than: 0, less_than_or_equal_to: 200)
    |> validate_inclusion(:lines, [1, 3, 5])
    |> validate_change(:badges, fn :badges, list ->
      cond do
        length(list) > length(@badges) -> [badges: "too many"]
        Enum.uniq(list) != list -> [badges: "repeats a badge"]
        Enum.any?(list, &(&1 not in @badges)) -> [badges: "names a badge the shop does not sell"]
        true -> []
      end
    end)
  end
end
