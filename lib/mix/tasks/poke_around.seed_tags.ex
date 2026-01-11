defmodule Mix.Tasks.PokeAround.SeedTags do
  @moduledoc """
  Creates initial tags and tags existing links by domain.

  ## Usage

      mix poke_around.seed_tags
  """

  use Mix.Task

  import Ecto.Query

  @shortdoc "Creates initial tags and tags links by domain"

  @impl Mix.Task
  def run(_args) do
    Application.ensure_all_started(:blog)

    alias Blog.PokeAround.{Tag, Link, Tags}
    alias Blog.Repo

    Mix.shell().info("Creating initial tags...")

    # Create basic tags
    tag_names = [
      "news", "weather", "video", "gardening", "cooking",
      "sports", "wikipedia", "tech", "world", "ukraine",
      "politics", "science", "entertainment", "music", "gaming"
    ]

    created_tags = for name <- tag_names do
      {:ok, tag} = Tags.get_or_create_tag(name)
      {name, tag}
    end |> Map.new()

    Mix.shell().info("Created #{map_size(created_tags)} tags")

    # Domain to tag mappings
    domain_tags = %{
      "nytimes.com" => ["news"],
      "theguardian.com" => ["news", "world"],
      "aljazeera.com" => ["news", "world"],
      "kyivindependent.com" => ["news", "ukraine", "world"],
      "lemonde.fr" => ["news", "world"],
      "weather.gov" => ["weather"],
      "mesonet.agron.iastate.edu" => ["weather"],
      "youtube.com" => ["video"],
      "youtu.be" => ["video"],
      "allforgardening.com" => ["gardening"],
      "diningandcooking.com" => ["cooking"],
      "eucup.com" => ["sports"],
      "en.wikipedia.org" => ["wikipedia"],
      "bbc.com" => ["news", "world"],
      "bbc.co.uk" => ["news", "world"],
      "cnn.com" => ["news"],
      "reuters.com" => ["news", "world"],
      "apnews.com" => ["news"],
      "npr.org" => ["news"],
      "washingtonpost.com" => ["news", "politics"],
      "politico.com" => ["news", "politics"],
      "arstechnica.com" => ["tech", "news"],
      "techcrunch.com" => ["tech", "news"],
      "wired.com" => ["tech"],
      "theverge.com" => ["tech"],
      "github.com" => ["tech"],
      "medium.com" => ["tech"],
      "dev.to" => ["tech"],
      "nature.com" => ["science"],
      "sciencemag.org" => ["science"],
      "space.com" => ["science"],
      "nasa.gov" => ["science"],
      "ign.com" => ["gaming", "entertainment"],
      "kotaku.com" => ["gaming"],
      "polygon.com" => ["gaming", "entertainment"],
      "variety.com" => ["entertainment"],
      "hollywoodreporter.com" => ["entertainment"],
      "pitchfork.com" => ["music", "entertainment"],
      "rollingstone.com" => ["music", "entertainment"]
    }

    # Tag links by domain
    total_tagged = Enum.reduce(domain_tags, 0, fn {domain, tag_names}, acc ->
      links = Repo.all(from l in Link, where: l.domain == ^domain)

      for link <- links, tag_name <- tag_names do
        if tag = created_tags[tag_name] do
          Tags.tag_link(link.id, tag.id, "domain_auto")
        end
      end

      count = length(links)
      if count > 0 do
        Mix.shell().info("Tagged #{count} links from #{domain}")
      end
      acc + count
    end)

    # Update usage counts
    Mix.shell().info("Updating tag usage counts...")
    for {_name, tag} <- created_tags do
      count = Repo.one(from lt in Blog.PokeAround.LinkTag, where: lt.tag_id == ^tag.id, select: count(lt.id))
      Repo.update!(Ecto.Changeset.change(tag, %{usage_count: count}))
    end

    Mix.shell().info("Done! Tagged #{total_tagged} links")
    Mix.shell().info("Total tags: #{Repo.aggregate(Tag, :count)}")
  end
end
