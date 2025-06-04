defmodule Blog.ContentTest do
  use ExUnit.Case, async: true
  alias Blog.Content
  alias Blog.Content.Tag

  import ExUnit.CaptureIO

  describe "list_posts/0" do
    test "returns list of posts" do
      posts = Content.list_posts()
      assert is_list(posts)

      for post <- posts do
        assert Map.has_key?(post, :title)
        assert Map.has_key?(post, :tags)
        assert Map.has_key?(post, :content)
        assert Map.has_key?(post, :written_on)
        assert Map.has_key?(post, :slug)

        assert is_binary(post.title)
        assert is_list(post.tags)
        assert is_binary(post.content)
        assert %Date{} = post.written_on
        assert is_binary(post.slug)
      end
    end

    test "posts are sorted by written_on in descending order" do
      posts = Content.list_posts()

      if length(posts) > 1 do
        dates = Enum.map(posts, & &1.written_on)
        sorted_dates = Enum.sort(dates, {:desc, Date})
        assert dates == sorted_dates
      end
    end
  end

  describe "categorize_posts/1" do
    setup do
      # Create test posts with different tag types
      tech_post = %{
        title: "Tech Post",
        tags: [%Tag{name: "elixir"}, %Tag{name: "programming"}],
        content: "Tech content",
        written_on: ~D[2025-01-01],
        slug: "tech-post"
      }

      non_tech_post = %{
        title: "Life Post",
        tags: [%Tag{name: "life"}, %Tag{name: "thoughts"}],
        content: "Life content",
        written_on: ~D[2025-01-02],
        slug: "life-post"
      }

      mixed_post = %{
        title: "Mixed Post",
        tags: [%Tag{name: "coding"}, %Tag{name: "life"}],
        content: "Mixed content",
        written_on: ~D[2025-01-03],
        slug: "mixed-post"
      }

      posts = [tech_post, non_tech_post, mixed_post]
      {:ok, posts: posts}
    end

    test "categorizes posts into tech and non-tech", %{posts: posts} do
      result = Content.categorize_posts(posts)

      assert Map.has_key?(result, :tech)
      assert Map.has_key?(result, :non_tech)
      assert is_list(result.tech)
      assert is_list(result.non_tech)
    end

    test "correctly identifies tech posts", %{posts: posts} do
      result = Content.categorize_posts(posts)

      tech_titles = Enum.map(result.tech, & &1.title)

      # Posts with tech tags should be in tech category
      assert "Tech Post" in tech_titles
      # Has "coding" tag
      assert "Mixed Post" in tech_titles
    end

    test "correctly identifies non-tech posts", %{posts: posts} do
      result = Content.categorize_posts(posts)

      non_tech_titles = Enum.map(result.non_tech, & &1.title)

      # Posts without tech tags should be in non-tech category  
      assert "Life Post" in non_tech_titles
    end

    test "sorts posts within categories by date descending", %{posts: posts} do
      # Add more posts to test sorting
      older_tech_post = %{
        title: "Older Tech Post",
        tags: [%Tag{name: "tech"}],
        content: "Old tech content",
        written_on: ~D[2024-12-01],
        slug: "older-tech-post"
      }

      newer_tech_post = %{
        title: "Newer Tech Post",
        tags: [%Tag{name: "software"}],
        content: "New tech content",
        written_on: ~D[2025-01-15],
        slug: "newer-tech-post"
      }

      all_posts = posts ++ [older_tech_post, newer_tech_post]
      result = Content.categorize_posts(all_posts)

      # Check tech posts are sorted by date descending
      tech_dates = Enum.map(result.tech, & &1.written_on)
      sorted_tech_dates = Enum.sort(tech_dates, {:desc, Date})
      assert tech_dates == sorted_tech_dates

      # Check non-tech posts are sorted by date descending  
      non_tech_dates = Enum.map(result.non_tech, & &1.written_on)
      sorted_non_tech_dates = Enum.sort(non_tech_dates, {:desc, Date})
      assert non_tech_dates == sorted_non_tech_dates
    end

    test "handles empty posts list" do
      result = Content.categorize_posts([])

      assert result.tech == []
      assert result.non_tech == []
    end

    test "handles posts with no tags" do
      no_tag_post = %{
        title: "No Tag Post",
        tags: [],
        content: "No tags",
        written_on: ~D[2025-01-01],
        slug: "no-tag-post"
      }

      result = Content.categorize_posts([no_tag_post])

      # Posts with no tags should go to non-tech
      assert length(result.non_tech) == 1
      assert length(result.tech) == 0
      assert hd(result.non_tech).title == "No Tag Post"
    end

    test "case insensitive tag matching" do
      uppercase_tech_post = %{
        title: "Uppercase Tech Post",
        tags: [%Tag{name: "ELIXIR"}, %Tag{name: "PROGRAMMING"}],
        content: "Uppercase tech content",
        written_on: ~D[2025-01-01],
        slug: "uppercase-tech-post"
      }

      result = Content.categorize_posts([uppercase_tech_post])

      # Should match despite uppercase
      assert length(result.tech) == 1
      assert hd(result.tech).title == "Uppercase Tech Post"
    end

    test "partial tag name matching" do
      partial_tech_post = %{
        title: "Partial Tech Post",
        # Contains "javascript"
        tags: [%Tag{name: "javascript-framework"}],
        content: "Partial tech content",
        written_on: ~D[2025-01-01],
        slug: "partial-tech-post"
      }

      result = Content.categorize_posts([partial_tech_post])

      # Should match because tag contains "javascript"
      assert length(result.tech) == 1
      assert hd(result.tech).title == "Partial Tech Post"
    end
  end
end
