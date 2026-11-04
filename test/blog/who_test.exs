defmodule Blog.WhoTest do
  @moduledoc """
  Blog.Who against the real export in priv/who. The numbers here are the
  file's, so a refreshed export that changes them should change the test.
  """
  use ExUnit.Case, async: true

  alias Blog.Who

  test "the export loads with the counts the explorer's README gives" do
    stats = Who.stats()
    assert stats.nodes == 2731
    assert stats.edges == 7728
    assert stats.stories == 384
    assert stats.decisions == 42
  end

  test "every incarnation is found, including the Fugitive Doctor" do
    doctors = Who.doctors()
    assert length(doctors) == 17
    assert Enum.map(doctors, & &1.ordinal) |> Enum.take(3) == ["First", "Second", "Third"]
    assert %{actor: "Jo Martin", years: "pre-Hartnell"} = Enum.find(doctors, &(&1.ordinal == "Fugitive"))
  end

  test "a Doctor can be named by number, ordinal or actor" do
    assert %{ordinal: "Tenth"} = Who.doctor(10)
    assert %{ordinal: "Tenth"} = Who.doctor("tenth")
    # Tennant played two; the earlier node wins, which is the one people mean
    assert %{ordinal: "Tenth"} = Who.doctor("Tennant")
    assert %{ordinal: "War"} = Who.doctor("Hurt")
    assert Who.doctor("Pertwee's cat") == nil
  end

  test "stories are filed under their Doctor and exclude companions and enemies" do
    tenth = Who.doctor(10)
    stories = Who.stories_of(tenth.id)
    titles = Enum.map(stories, & &1.title)

    assert Enum.any?(titles, &String.starts_with?(&1, "Blink"))
    refute Enum.any?(titles, &String.starts_with?(&1, "Rose Tyler"))
    refute Enum.any?(titles, &String.starts_with?(&1, "The Daleks"))
  end

  test "search scores by words, so a title fragment finds the node first" do
    assert [%{title: "Blink - Sally Sparrow, timey-wimey, Angels"} | _] = Who.search_nodes("Sally Sparrow timey")
    assert Who.search_nodes("of") == []
  end

  test "a tie on words is a tie: 'Blink Angels' scores the Weeping Angels node the same as Blink" do
    # Both titles contain both words. Scoring is a word count, as on the
    # other explorers, and the lower id wins a tie; the chat is told to retry
    # with different words rather than trust the first hit.
    [first, second | _] = Who.search_nodes("Blink Angels")
    assert first.title =~ "Weeping Angels"
    assert second.title =~ "Blink -"
  end

  test "neighbours carry the rationale as the relation" do
    [blink] = Who.search_nodes("Blink Sally Sparrow", limit: 1)
    %{outgoing: out} = Who.neighbors(blink.id)
    assert Enum.any?(out, &(&1.relation == "Doctor" and &1.title =~ "Tenth Doctor"))
  end

  test "a chain walks the sequence edges and stops at the end" do
    [ambassadors] = Who.search_nodes("Ambassadors of Death", limit: 1)
    chain = Who.chain(ambassadors.id, :forward, 3)
    assert hd(chain).id == ambassadors.id
    assert Enum.any?(chain, &String.starts_with?(&1.title, "Inferno"))
    assert length(chain) <= 4
  end

  test "the decisions come with their options and outcomes" do
    genesis = Enum.find(Who.decisions(), &(&1.title =~ "Daleks at their creation"))
    assert genesis
    assert Enum.any?(genesis.options, &(&1 =~ "Destroy Daleks"))
    assert Enum.any?(genesis.outcomes, &(&1 =~ "Daleks survive"))
  end

  test "a TV story's wiki record is there by title" do
    blink = Who.episode("blink")
    assert blink.writer == "Steven Moffat"
    assert blink.enemies == ["Weeping Angels"]
    # the scrape is thin here: no Doctor, no companions, no air date for Blink
    assert blink.doctor == nil
    assert blink.companions == []
    assert Who.episode_summary(blink) |> Map.has_key?(:synopsis) == false
    assert Who.episode_summary(blink, full: true).synopsis =~ "Blink"
    assert Who.episode("not a story") == nil
  end

  test "story search reads the whole record, not just the title" do
    titles = Who.search_episodes("Moffat Angels") |> Enum.map(& &1.title)
    assert "Blink" in titles
  end
end
