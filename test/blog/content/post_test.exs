defmodule Blog.Content.PostTest do
  use ExUnit.Case, async: true
  alias Blog.Content.Post
  alias Blog.Content.Tag

  describe "Post struct" do
    test "has correct fields" do
      post = %Post{
        body: "# Test\nContent",
        title: "Test Post",
        written_on: ~N[2025-01-01 12:00:00],
        tags: [%Tag{name: "test"}],
        slug: "test-post"
      }

      assert post.body == "# Test\nContent"
      assert post.title == "Test Post"
      assert post.written_on == ~N[2025-01-01 12:00:00]
      assert post.tags == [%Tag{name: "test"}]
      assert post.slug == "test-post"
    end
  end

  describe "all/0" do
    test "returns list of posts sorted by date descending" do
      posts = Post.all()
      assert is_list(posts)

      # Check that all posts have required fields
      for post <- posts do
        assert %Post{} = post
        assert is_binary(post.body)
        assert is_binary(post.title)
        assert %NaiveDateTime{} = post.written_on
        assert is_binary(post.slug)
        assert is_list(post.tags)
      end

      # Check sorting - dates should be in descending order
      dates = Enum.map(posts, & &1.written_on)
      sorted_dates = Enum.sort(dates, {:desc, NaiveDateTime})
      assert dates == sorted_dates
    end

    test "filters out files with specific length pattern" do
      # This tests the rejection logic for files with 35-character endings
      posts = Post.all()

      # All returned posts should have valid slug formats
      for post <- posts do
        refute String.length(post.slug) == 35
      end
    end
  end

  describe "get_by_slug/1" do
    test "returns post when slug exists" do
      posts = Post.all()

      case posts do
        [first_post | _] ->
          found_post = Post.get_by_slug(first_post.slug)
          assert found_post == first_post

        [] ->
          # If no posts exist, test with nil
          assert Post.get_by_slug("nonexistent") == nil
      end
    end

    test "returns nil when slug doesn't exist" do
      result = Post.get_by_slug("nonexistent-slug-that-should-not-exist")
      assert result == nil
    end
  end

  describe "private functions behavior" do
    test "humanize_title/1 converts slug to title case" do
      # We can't test private functions directly, but we can test through parse_post_file
      # by creating a temporary test file if needed, or test the behavior through public functions

      posts = Post.all()

      for post <- posts do
        # Title should be properly capitalized
        words = String.split(post.title, " ")

        for word <- words do
          if String.length(word) > 0 do
            first_char = String.first(word)

            assert first_char == String.upcase(first_char),
                   "Expected #{word} to start with uppercase letter in title: #{post.title}"
          end
        end
      end
    end

    test "parse_datetime creates valid NaiveDateTime" do
      # Test through existing posts that they have valid datetimes
      posts = Post.all()

      for post <- posts do
        assert %NaiveDateTime{} = post.written_on
        # Should be a reasonable date (after 2020, before 2030)
        assert post.written_on.year >= 2020
        assert post.written_on.year <= 2030
      end
    end

    test "parse_tags extracts tags correctly" do
      posts = Post.all()

      for post <- posts do
        assert is_list(post.tags)

        for tag <- post.tags do
          assert %Tag{} = tag
          assert is_binary(tag.name)
          assert String.trim(tag.name) == tag.name, "Tag name should be trimmed"
        end
      end
    end
  end
end
