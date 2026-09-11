defmodule Blog.GalleryEmptyTest do
  use ExUnit.Case, async: true

  # Apple has been observed serving `itemsReturned: 0` for a shared album it
  # reports as unchanged (identical streamCtag). Believing that would blank
  # every open page, so the cache keeps what it has until the emptiness
  # repeats. These pin the tolerance rule itself.

  @tolerance 3

  defp keep?(%{photos: photos, empty_streak: streak}, incoming) do
    incoming == [] and photos != [] and streak < @tolerance
  end

  test "an empty response for a populated album is ignored" do
    state = %{photos: [:a, :b], empty_streak: 0}
    assert keep?(state, [])
  end

  test "it stops being ignored once the streak reaches the tolerance" do
    state = %{photos: [:a, :b], empty_streak: @tolerance}
    refute keep?(state, [])
  end

  test "an album that was already empty has nothing to protect" do
    state = %{photos: [], empty_streak: 0}
    refute keep?(state, [])
  end

  test "a non-empty response is never suppressed" do
    state = %{photos: [:a], empty_streak: 1}
    refute keep?(state, [:a, :b])
  end
end
