defmodule Blog.Repo.Migrations.SeedFinderData do
  use Ecto.Migration

  def up do
    %{rows: [[count]]} = repo().query!("SELECT COUNT(*) FROM finder_sections")

    if count == 0 do
      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      sections = [
        %{name: "games", sort_order: 0, joyride_target: "games-section", label: nil, visible: true,
          items: [
            %{name: "Pong", icon: "🏓", path: "/pong", sort_order: 0},
            %{name: "Pong God View", icon: "👁️", path: "/pong/god", sort_order: 1},
            %{name: "Wordle", icon: "🔤", path: "/wordle", sort_order: 2},
            %{name: "Wordle God", icon: "🎯", path: "/wordle_god", sort_order: 3},
            %{name: "Blackjack", icon: "🃏", path: "/blackjack", sort_order: 4},
            %{name: "War", icon: "⚔️", path: "/war", sort_order: 5}
          ]},
        %{name: "creative", sort_order: 1, joyride_target: "creative-section", label: nil, visible: true,
          items: [
            %{name: "Art", icon: "🎨", path: "/generative-art", sort_order: 0},
            %{name: "Bezier", icon: "📐", path: "/bezier-triangles", sort_order: 1},
            %{name: "Chaos", icon: "🌈", path: "/gay_chaos", sort_order: 2},
            %{name: "Cursor", icon: "🖱️", path: "/cursor-tracker", sort_order: 3},
            %{name: "Typewriter", icon: "⌨️", path: "/typewriter", sort_order: 4},
            %{name: "Code Mirror", icon: "🪞", path: "/mirror", sort_order: 5},
            %{name: "Python", icon: "🐍", path: "/python-demo", sort_order: 6},
            %{name: "Markdown", icon: "✍️", path: "/markdown-editor", sort_order: 7}
          ]},
        %{name: "bluesky", sort_order: 2, joyride_target: "bluesky-section", label: nil, visible: true,
          items: [
            %{name: "Emoji Skeets", icon: "😀", path: "/emoji-skeets", sort_order: 0},
            %{name: "Bluesky YT", icon: "📺", path: "/reddit-links", sort_order: 1},
            %{name: "No Words Chat", icon: "💬", path: "/allowed-chats", sort_order: 2}
          ]},
        %{name: "nathan", sort_order: 3, joyride_target: "nathan-section", label: nil, visible: true,
          items: [
            %{name: "Nathan", icon: "😐", path: "/nathan", sort_order: 0},
            %{name: "Nathan HP", icon: "📖", path: "/nathan_harpers", sort_order: 1},
            %{name: "Nathan TV", icon: "👗", path: "/nathan_teen_vogue", sort_order: 2},
            %{name: "Nathan BF", icon: "📋", path: "/nathan_buzzfeed", sort_order: 3},
            %{name: "Nathan UN", icon: "💻", path: "/nathan_usenet", sort_order: 4},
            %{name: "Nathan CF", icon: "🌾", path: "/nathan_content_farm", sort_order: 5},
            %{name: "Nathan Cmp", icon: "⚖️", path: "/nathan_comparison", sort_order: 6},
            %{name: "Nathan ASCII", icon: "🔣", path: "/nathan_ascii", sort_order: 7}
          ]},
        %{name: "maps", sort_order: 4, joyride_target: "maps-section", label: nil, visible: true,
          items: [
            %{name: "NYC Census", icon: "🗽", path: "/nyc_census_and_pluto", sort_order: 0},
            %{name: "MTA Map", icon: "🚌", path: "/mta-bus-map", sort_order: 1}
          ]},
        %{name: "utilities", sort_order: 5, joyride_target: "utilities-section", label: nil, visible: true,
          items: [
            %{name: "Blog", icon: "📝", path: "/blog", sort_order: 0},
            %{name: "HN", icon: "📡", path: "/hacker-news", sort_order: 1},
            %{name: "Bookmarks", icon: "🔖", path: "/bookmarks", sort_order: 2},
            %{name: "Role Call", icon: "📺", path: "/role-call", sort_order: 3},
            %{name: "300+ Yrs Tree Law", icon: "🌳", path: "/trees", sort_order: 4},
            %{name: "Receipt", icon: "🧾", path: "/very_direct_message", sort_order: 5}
          ]},
        %{name: "music", sort_order: 6, joyride_target: nil, label: nil, visible: true,
          items: [
            %{name: "Phish Stats", icon: "🐟", path: nil, sort_order: 0, action: "toggle_phish"}
          ]},
        %{name: "other", sort_order: 7, joyride_target: nil, label: nil, visible: true,
          items: [
            %{name: "Trash", icon: "🗑️", path: nil, sort_order: 0}
          ]}
      ]

      for section <- sections do
        {items, section_attrs} = Map.pop(section, :items)

        section_row =
          section_attrs
          |> Map.put(:inserted_at, now)
          |> Map.put(:updated_at, now)

        {1, [%{id: section_id}]} =
          repo().insert_all("finder_sections", [section_row], returning: [:id])

        item_rows =
          Enum.map(items, fn item ->
            %{
              name: item.name,
              icon: item.icon,
              path: Map.get(item, :path),
              sort_order: item.sort_order,
              joyride_target: Map.get(item, :joyride_target),
              action: Map.get(item, :action),
              visible: Map.get(item, :visible, true),
              section_id: section_id,
              inserted_at: now,
              updated_at: now
            }
          end)

        repo().insert_all("finder_items", item_rows)
      end
    end
  end

  def down do
    execute("DELETE FROM finder_items")
    execute("DELETE FROM finder_sections")
  end
end
