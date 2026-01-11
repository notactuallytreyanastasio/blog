defmodule Blog.PokeAround.Bluesky.Types do
  @moduledoc """
  Type definitions for Turbostream events.

  Turbostream provides hydrated events - profiles, mentions, and
  parent posts are already resolved inline.
  """

  defmodule Author do
    @moduledoc "Hydrated author profile from Turbostream."

    defstruct [
      :did,
      :handle,
      :display_name,
      :avatar,
      :description,
      :followers_count,
      :follows_count,
      :posts_count,
      :indexed_at
    ]

    @type t :: %__MODULE__{
            did: String.t(),
            handle: String.t(),
            display_name: String.t() | nil,
            avatar: String.t() | nil,
            description: String.t() | nil,
            followers_count: non_neg_integer() | nil,
            follows_count: non_neg_integer() | nil,
            posts_count: non_neg_integer() | nil,
            indexed_at: DateTime.t() | nil
          }
  end

  defmodule ExternalEmbed do
    @moduledoc "External link card embed."

    defstruct [:uri, :title, :description, :thumb]

    @type t :: %__MODULE__{
            uri: String.t(),
            title: String.t() | nil,
            description: String.t() | nil,
            thumb: map() | nil
          }
  end

  defmodule FacetLink do
    @moduledoc "A link found in post text via facets."

    defstruct [:uri, :byte_start, :byte_end]

    @type t :: %__MODULE__{
            uri: String.t(),
            byte_start: non_neg_integer(),
            byte_end: non_neg_integer()
          }
  end

  defmodule Post do
    @moduledoc "A parsed Bluesky post with extracted data."

    defstruct [
      :uri,
      :cid,
      :text,
      :created_at,
      :author,
      :external_embed,
      :facet_links,
      :langs,
      :reply_to,
      :is_reply
    ]

    @type t :: %__MODULE__{
            uri: String.t(),
            cid: String.t(),
            text: String.t(),
            created_at: DateTime.t() | nil,
            author: Author.t() | nil,
            external_embed: ExternalEmbed.t() | nil,
            facet_links: [FacetLink.t()],
            langs: [String.t()] | nil,
            reply_to: String.t() | nil,
            is_reply: boolean()
          }
  end
end
