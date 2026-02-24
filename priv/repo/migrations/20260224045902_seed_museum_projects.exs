defmodule Blog.Repo.Migrations.SeedMuseumProjects do
  use Ecto.Migration

  def up do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    projects = [
      %{slug: "deciduous", title: "Deciduous", tagline: "Decision graph CLI for tracing how software decisions evolve",
        description: "A Rust CLI tool that builds a directed graph of your software decisions as you make them.\nEvery goal, action, decision, and outcome gets logged in real-time and linked together.\nIncludes a web viewer, git commit linking, branch-based grouping, and multi-user sync via patches.\nShips via Homebrew tap.",
        category: "tools", tech_stack: ["Rust", "SQLite", "HTML/JS"],
        github_repos: [%{"name" => "deciduous", "full_name" => "notactuallytreyanastasio/deciduous"}],
        internal_path: nil, external_url: nil, pixel_art_path: "/images/museum/deciduous.png",
        emoji: "🌳", color: "#2d5a27", sort_order: 1, visible: true, inserted_at: now, updated_at: now},

      %{slug: "losselot", title: "Losselot", tagline: "Neural network loss function explorer",
        description: "An interactive tool for exploring and comparing neural network loss functions.\nVisualizes how different loss functions behave across parameter spaces.",
        category: "ml", tech_stack: ["Python"],
        github_repos: [%{"name" => "losselot", "full_name" => "notactuallytreyanastasio/losselot"}],
        internal_path: nil, external_url: nil, pixel_art_path: "/images/museum/losselot.png",
        emoji: "⚔️", color: "#8b4513", sort_order: 2, visible: true, inserted_at: now, updated_at: now},

      %{slug: "phangraphs", title: "Phish Explorer", tagline: "Jam analytics dashboard for Phish 3.0 era",
        description: "A comprehensive analytics dashboard for Phish jam data. Filter by year and song,\nsee batting averages for jams, duration timelines, jamchart rates, and flip through\ndetailed cards for every notable performance. Built as a Phoenix LiveView with D3 charts.",
        category: "music", tech_stack: ["Elixir", "Phoenix LiveView", "D3.js"],
        github_repos: [],
        internal_path: "/phish", external_url: nil, pixel_art_path: "/images/museum/phangraphs.png",
        emoji: "🎸", color: "#6b21a8", sort_order: 3, visible: true, inserted_at: now, updated_at: now},

      %{slug: "local-llm", title: "Local LLM on MacBook", tagline: "4-bit quantization, safetensors, and Bumblebee + EMLX for Apple Silicon",
        description: "A series of libraries and experiments to run large language models locally on a MacBook Pro.\nIncludes a safetensors parser for Elixir, 4-bit quantization support for Bumblebee,\nand EMLX bindings to leverage Apple's MLX framework from Elixir. The goal: run inference\non Apple Silicon without leaving the BEAM.",
        category: "ml", tech_stack: ["Elixir", "Rust", "Python", "MLX"],
        github_repos: [
          %{"name" => "bumblebee", "full_name" => "notactuallytreyanastasio/bumblebee"},
          %{"name" => "emlx", "full_name" => "notactuallytreyanastasio/emlx"},
          %{"name" => "bumblebee_quantized", "full_name" => "notactuallytreyanastasio/bumblebee_quantized"},
          %{"name" => "safetensors_ex", "full_name" => "notactuallytreyanastasio/safetensors_ex"}
        ],
        internal_path: nil, external_url: nil, pixel_art_path: "/images/museum/local-llm.png",
        emoji: "🧠", color: "#1e40af", sort_order: 4, visible: true, inserted_at: now, updated_at: now},

      %{slug: "role-call", title: "Role Call", tagline: "TV writer overlap explorer",
        description: "Explore which TV writers have worked together across different shows.\nDiscover unexpected connections in the television writing world.",
        category: "social", tech_stack: ["Elixir", "Phoenix LiveView"],
        github_repos: [%{"name" => "role-call", "full_name" => "notactuallytreyanastasio/role-call"}],
        internal_path: "/role-call", external_url: nil, pixel_art_path: "/images/museum/role-call.png",
        emoji: "🎬", color: "#dc2626", sort_order: 5, visible: true, inserted_at: now, updated_at: now},

      %{slug: "ormery", title: "Ormery", tagline: "An ORM written in Temper",
        description: "A from-scratch ORM built in the Temper programming language. Explores what database\nabstractions look like in a language with a novel type system. Handles schema definition,\nquery building, and migrations.",
        category: "tools", tech_stack: ["Temper"],
        github_repos: [%{"name" => "ormery", "full_name" => "notactuallytreyanastasio/ormery"}],
        internal_path: nil, external_url: nil, pixel_art_path: "/images/museum/ormery.png",
        emoji: "🗄️", color: "#ea580c", sort_order: 6, visible: true, inserted_at: now, updated_at: now},

      %{slug: "bobby-posts", title: "Bobby Posts Bot", tagline: "A bot that posts like me, in Python",
        description: "A Python bot trained on my writing style that generates and posts content that sounds like me.\nUses fine-tuned language model adapters to capture voice and topic preferences.",
        category: "ml", tech_stack: ["Python"],
        github_repos: [
          %{"name" => "bobby_posts", "full_name" => "notactuallytreyanastasio/bobby_posts"},
          %{"name" => "bobby_posts_adapters", "full_name" => "notactuallytreyanastasio/bobby_posts_adapters"}
        ],
        internal_path: nil, external_url: nil, pixel_art_path: "/images/museum/bobby-posts.png",
        emoji: "🤖", color: "#7c3aed", sort_order: 7, visible: true, inserted_at: now, updated_at: now},

      %{slug: "bobby-posts-elixir", title: "Bobby Posts (Elixir)", tagline: "Porting the posting bot to Elixir using local LLM work",
        description: "An Elixir version of the Bobby Posts bot, leveraging the Bumblebee quantization\nand EMLX work to run inference on the BEAM. Proves the full local-LLM-in-Elixir\npipeline works end-to-end.",
        category: "ml", tech_stack: ["Elixir", "Bumblebee", "EMLX"],
        github_repos: [],
        internal_path: nil, external_url: nil, pixel_art_path: "/images/museum/bobby-posts-elixir.png",
        emoji: "💜", color: "#9333ea", sort_order: 8, visible: true, inserted_at: now, updated_at: now},

      %{slug: "pocket-pnin", title: "Pocket Pnin", tagline: "A local LLM running on my iPhone, coming to the App Store for free",
        description: "An iPhone app that runs language model inference entirely on-device using Apple's MLX framework.\nA truly portable, offline-capable AI assistant in your pocket. Built in Swift with a clean native UI.\nWill be released for free on the App Store.",
        category: "ml", tech_stack: ["Swift", "MLX"],
        github_repos: [],
        internal_path: nil, external_url: nil, pixel_art_path: "/images/museum/pocket-pnin.png",
        emoji: "📱", color: "#0891b2", sort_order: 9, visible: true, inserted_at: now, updated_at: now},

      %{slug: "genstage-2025", title: "GenStage Tutorial 2025", tagline: "A modern GenStage tutorial for the Elixir ecosystem",
        description: "An updated, comprehensive tutorial on Elixir's GenStage for building\ndata processing pipelines. Covers producers, consumers, back-pressure,\nand real-world patterns with modern Elixir.",
        category: "writing", tech_stack: ["Elixir", "GenStage"],
        github_repos: [%{"name" => "genstage_tutorial_2025", "full_name" => "notactuallytreyanastasio/genstage_tutorial_2025"}],
        internal_path: nil, external_url: nil, pixel_art_path: "/images/museum/genstage-2025.png",
        emoji: "⚙️", color: "#4f46e5", sort_order: 10, visible: true, inserted_at: now, updated_at: now},

      %{slug: "tree-law", title: "300+ Years of Tree Law", tagline: "A blog post that became its own LiveView application",
        description: "What started as a blog post about the surprisingly deep history of tree law\ngrew into a full interactive LiveView application. Covers centuries of legal\nprecedent around trees, property rights, and neighbor disputes.",
        category: "writing", tech_stack: ["Elixir", "Phoenix LiveView"],
        github_repos: [],
        internal_path: "/trees", external_url: nil, pixel_art_path: "/images/museum/tree-law.png",
        emoji: "⚖️", color: "#166534", sort_order: 11, visible: true, inserted_at: now, updated_at: now},

      %{slug: "temper-rust-bug", title: "Temper Rust Bug", tagline: "Found a bug in the Temper compiler and built a demo repo",
        description: "While working with the Temper programming language, I discovered a bug in its\nRust backend. Built a minimal reproduction repository and documented the issue.",
        category: "tools", tech_stack: ["Temper", "Rust"],
        github_repos: [%{"name" => "temper_rust_bug_maybe", "full_name" => "notactuallytreyanastasio/temper_rust_bug_maybe"}],
        internal_path: nil, external_url: nil, pixel_art_path: "/images/museum/temper-rust-bug.png",
        emoji: "🐛", color: "#b91c1c", sort_order: 12, visible: true, inserted_at: now, updated_at: now},

      %{slug: "heex-polyglot", title: "HEEx in Other Languages", tagline: "Experiments porting Phoenix HEEx templates to Rust, Lua, C#, Java, Python, and JS",
        description: "A series of experiments using Temper to port Phoenix's HEEx template engine to\nsix other programming languages. Explores what Phoenix-style server-rendered\ntemplates look like outside the Elixir ecosystem.",
        category: "tools", tech_stack: ["Temper", "Rust", "Lua", "C#", "Java", "Python", "JavaScript"],
        github_repos: [
          %{"name" => "heex-rs", "full_name" => "notactuallytreyanastasio/heex-rs"},
          %{"name" => "heex-lua", "full_name" => "notactuallytreyanastasio/heex-lua"},
          %{"name" => "heex-csharp", "full_name" => "notactuallytreyanastasio/heex-csharp"},
          %{"name" => "heex-java", "full_name" => "notactuallytreyanastasio/heex-java"},
          %{"name" => "heex-py", "full_name" => "notactuallytreyanastasio/heex-py"},
          %{"name" => "heex-js", "full_name" => "notactuallytreyanastasio/heex-js"}
        ],
        internal_path: nil, external_url: nil, pixel_art_path: "/images/museum/heex-polyglot.png",
        emoji: "🌐", color: "#f59e0b", sort_order: 13, visible: true, inserted_at: now, updated_at: now},

      %{slug: "receipt-printer", title: "Receipt Printer Software Suite", tagline: "A complete software suite for thermal receipt printers",
        description: "Software for driving thermal receipt printers for creative and practical uses.\nIncludes drivers, formatting libraries, and integration with various input sources.\nPowers the photo booth, remote printing, and direct message receipt features.",
        category: "hardware", tech_stack: ["Elixir", "Python"],
        github_repos: [
          %{"name" => "receipts", "full_name" => "notactuallytreyanastasio/receipts"},
          %{"name" => "read_my_receipts", "full_name" => "notactuallytreyanastasio/read_my_receipts"}
        ],
        internal_path: nil, external_url: nil, pixel_art_path: "/images/museum/receipt-printer.png",
        emoji: "🧾", color: "#78716c", sort_order: 14, visible: true, inserted_at: now, updated_at: now},

      %{slug: "live-draft-lsp", title: "Live Draft LSP", tagline: "Live-stream blog drafts from Zed to Phoenix via a custom LSP",
        description: "A Language Server Protocol implementation that streams your blog drafts in real-time\nfrom the Zed editor to a Phoenix LiveView. Includes a Zed extension and a Phoenix\nAPI endpoint. Readers can watch you write.",
        category: "tools", tech_stack: ["Rust", "Elixir", "Zed"],
        github_repos: [
          %{"name" => "live_draft_lsp", "full_name" => "notactuallytreyanastasio/live_draft_lsp"},
          %{"name" => "zed-live-draft", "full_name" => "notactuallytreyanastasio/zed-live-draft"}
        ],
        internal_path: nil, external_url: nil, pixel_art_path: "/images/museum/live-draft-lsp.png",
        emoji: "✏️", color: "#0284c7", sort_order: 15, visible: true, inserted_at: now, updated_at: now},

      %{slug: "todoinksies", title: "Todoinksies", tagline: "A personal todo app",
        description: "A personal todo application built for my own workflow.",
        category: "tools", tech_stack: ["Elixir", "Phoenix LiveView"],
        github_repos: [%{"name" => "todoinksies", "full_name" => "notactuallytreyanastasio/todoinksies"}],
        internal_path: nil, external_url: nil, pixel_art_path: "/images/museum/todoinksies.png",
        emoji: "📝", color: "#ec4899", sort_order: 16, visible: true, inserted_at: now, updated_at: now},

      %{slug: "archive-tv", title: "Archive TV", tagline: "A real over-the-air TV channel from magnetic media archives",
        description: "Software that turns a collection of digitized magnetic media (VHS tapes, etc.) into\nan actual broadcast TV channel in our house. Integrates with the archive to schedule\nand transmit content over the air using a software-defined radio.",
        category: "hardware", tech_stack: ["Elixir", "FFmpeg"],
        github_repos: [%{"name" => "archive_tv", "full_name" => "notactuallytreyanastasio/archive_tv"}],
        internal_path: nil, external_url: nil, pixel_art_path: "/images/museum/archive-tv.png",
        emoji: "📺", color: "#374151", sort_order: 17, visible: true, inserted_at: now, updated_at: now},

      %{slug: "deciduous-archaeology", title: "Deciduous Archaeology Demos", tagline: "Demonstrations of decision archaeology on React and stacked git workflows",
        description: "Showcases of using Deciduous to retroactively trace decision histories in existing\ncodebases. Includes demos on a React project and a stacked-git workflow, showing\nhow to reconstruct the reasoning behind past architectural choices.",
        category: "tools", tech_stack: ["Rust", "React", "Git"],
        github_repos: [%{"name" => "deciduous", "full_name" => "notactuallytreyanastasio/deciduous"}],
        internal_path: nil, external_url: nil, pixel_art_path: "/images/museum/deciduous-archaeology.png",
        emoji: "🏺", color: "#92400e", sort_order: 18, visible: true, inserted_at: now, updated_at: now},

      %{slug: "bluesky-hoovers", title: "Bluesky Hoover Apps", tagline: "Various apps that vacuum up and process the Bluesky firehose",
        description: "A collection of applications that consume the Bluesky/AT Protocol firehose\nfor different purposes: link curation, content filtering, community discovery,\nand real-time feed processing.",
        category: "social", tech_stack: ["Elixir", "Phoenix LiveView"],
        github_repos: [
          %{"name" => "atmospheric_hoover", "full_name" => "notactuallytreyanastasio/atmospheric_hoover"},
          %{"name" => "bluesky_firehose", "full_name" => "notactuallytreyanastasio/bluesky_firehose"},
          %{"name" => "poke_around", "full_name" => "notactuallytreyanastasio/poke_around"}
        ],
        internal_path: nil, external_url: nil, pixel_art_path: "/images/museum/bluesky-hoovers.png",
        emoji: "🦋", color: "#0ea5e9", sort_order: 19, visible: true, inserted_at: now, updated_at: now},

      %{slug: "photo-booth", title: "Photo Booth Receipt Printer", tagline: "A portable photo booth that prints on receipt paper",
        description: "A portable photo booth project that captures photos and prints them as strips\non a thermal receipt printer. Combines hardware tinkering with creative software\nto make a fun party/event fixture.",
        category: "hardware", tech_stack: ["Python", "Elixir"],
        github_repos: [%{"name" => "photo_booth", "full_name" => "notactuallytreyanastasio/photo_booth"}],
        internal_path: nil, external_url: nil, pixel_art_path: "/images/museum/photo-booth.png",
        emoji: "📸", color: "#be185d", sort_order: 20, visible: true, inserted_at: now, updated_at: now},

      %{slug: "send-photo", title: "Send Me a Photo From Your Day", tagline: "A social project where friends send photos that print on my receipt printer",
        description: "A social experiment where friends can send me a photo from their day and it prints\ndirectly on my receipt printer at home. Grew out of the photo booth and receipt printer\nsoftware suite. A physical, tangible way to stay connected.",
        category: "hardware", tech_stack: ["Elixir", "Phoenix LiveView"],
        github_repos: [],
        internal_path: "/very_direct_message", external_url: nil, pixel_art_path: "/images/museum/send-photo.png",
        emoji: "💌", color: "#e11d48", sort_order: 21, visible: true, inserted_at: now, updated_at: now},

      %{slug: "nathan-for-us", title: "Nathan For Us", tagline: "A Nathan For You social network with video search and GIF creation",
        description: "A social network dedicated entirely to Nathan For You content. Features video search\nby caption file, GIF creation from show clips, and community features. Was accidentally\nuseful as a general-purpose video search and GIF tool.",
        category: "social", tech_stack: ["Elixir", "Phoenix LiveView", "FFmpeg", "yt-dlp"],
        github_repos: [%{"name" => "nathan_for_us", "full_name" => "notactuallytreyanastasio/nathan_for_us"}],
        internal_path: nil, external_url: nil, pixel_art_path: "/images/museum/nathan-for-us.png",
        emoji: "🎭", color: "#1d4ed8", sort_order: 22, visible: true, inserted_at: now, updated_at: now},

      %{slug: "browser-mcp", title: "Browser History Roast MCP", tagline: "An MCP server that roasts you based on your browser history",
        description: "A Model Context Protocol server that reads your browser history and generates\nroasts about your browsing habits. Includes a screenshot judgement mode and\na dedicated roasting interface.",
        category: "ml", tech_stack: ["Python", "MCP"],
        github_repos: [
          %{"name" => "browser_mcp", "full_name" => "notactuallytreyanastasio/browser_mcp"},
          %{"name" => "roasted", "full_name" => "notactuallytreyanastasio/roasted"},
          %{"name" => "screenshot_judgement", "full_name" => "notactuallytreyanastasio/screenshot_judgement"}
        ],
        internal_path: nil, external_url: nil, pixel_art_path: "/images/museum/browser-mcp.png",
        emoji: "🔥", color: "#dc2626", sort_order: 23, visible: true, inserted_at: now, updated_at: now},

      %{slug: "genstage-original", title: "GenStage Tutorial (Original)", tagline: "The original GenStage tutorial",
        description: "The original GenStage tutorial that kicked off a series of Elixir data pipeline\nexplorations. Covers the fundamentals of producers, consumers, and back-pressure.",
        category: "writing", tech_stack: ["Elixir", "GenStage"],
        github_repos: [%{"name" => "genstage_tutorial", "full_name" => "notactuallytreyanastasio/genstage_tutorial"}],
        internal_path: nil, external_url: nil, pixel_art_path: "/images/museum/genstage-original.png",
        emoji: "📚", color: "#6366f1", sort_order: 24, visible: true, inserted_at: now, updated_at: now},

      %{slug: "nyc-census", title: "NYC Census Maps", tagline: "Interactive census and PLUTO data visualization for New York City",
        description: "Draw on a map of New York City and get instant population estimates for the area.\nCombines 2020 Census data with NYC PLUTO tax lot data. Features a toggleable\npopulation density heatmap overlay.",
        category: "maps", tech_stack: ["Elixir", "Phoenix LiveView", "Leaflet.js"],
        github_repos: [],
        internal_path: "/nyc_census_and_pluto", external_url: nil, pixel_art_path: "/images/museum/nyc-census.png",
        emoji: "🗽", color: "#059669", sort_order: 25, visible: true, inserted_at: now, updated_at: now},

      %{slug: "gif-maker", title: "Concert GIF Maker", tagline: "Extract GIFs from concert videos with a retro Mac interface",
        description: "A web tool that extracts segments from YouTube concert videos and converts them\nto high-quality GIFs using a two-pass FFmpeg pipeline. Features frame selection,\noverlay text, math CAPTCHA verification, and a retro Mac OS interface.",
        category: "music", tech_stack: ["Elixir", "Phoenix LiveView", "FFmpeg", "yt-dlp"],
        github_repos: [],
        internal_path: "/gif-maker", external_url: nil, pixel_art_path: "/images/museum/gif-maker.png",
        emoji: "🎞️", color: "#7c3aed", sort_order: 26, visible: true, inserted_at: now, updated_at: now},

      %{slug: "fill-your-sky", title: "Fill Your Sky", tagline: "Interactive map of 418+ Bluesky communities with 545K+ people",
        description: "A D3/Canvas visualization mapping the community structure of Bluesky.\nDiscovered via graph analysis of the social network. Browse 418+ communities,\nsee how they connect, and find your place in the network.",
        category: "maps", tech_stack: ["Elixir", "Phoenix LiveView", "D3.js", "Deck.GL"],
        github_repos: [%{"name" => "fill_your_sky", "full_name" => "notactuallytreyanastasio/fill_your_sky"}],
        internal_path: "/sky", external_url: nil, pixel_art_path: "/images/museum/fill-your-sky.png",
        emoji: "🌌", color: "#1e3a5f", sort_order: 27, visible: true, inserted_at: now, updated_at: now},

      %{slug: "bluesky-firehose-toys", title: "Bluesky Firehose Toys", tagline: "Real-time firehose visualizations: emoji streams, jetstream comparisons, and more",
        description: "A collection of real-time visualizations built on the Bluesky AT Protocol firehose.\nWatch emoji usage across the network, compare different firehose relay performance,\nand browse YouTube videos shared on Bluesky.",
        category: "social", tech_stack: ["Elixir", "Phoenix LiveView", "WebSocket"],
        github_repos: [],
        internal_path: "/emoji-skeets", external_url: nil, pixel_art_path: "/images/museum/bluesky-firehose-toys.png",
        emoji: "🌊", color: "#0369a1", sort_order: 28, visible: true, inserted_at: now, updated_at: now},

      %{slug: "code-mirror", title: "Code Mirror", tagline: "A live code mirror experiment",
        description: "An interactive code mirror that reflects and transforms input in real-time.",
        category: "tools", tech_stack: ["Elixir", "Phoenix LiveView"],
        github_repos: [],
        internal_path: "/mirror", external_url: nil, pixel_art_path: "/images/museum/code-mirror.png",
        emoji: "🪞", color: "#475569", sort_order: 29, visible: true, inserted_at: now, updated_at: now},

      %{slug: "collage-maker", title: "Collage Maker", tagline: "Upload photos and arrange them into grid collages",
        description: "A web tool for creating photo collages. Upload 2-36 images, configure the grid\nlayout, randomize arrangement, and download a full-resolution collage. Features\nmath CAPTCHA and rate limiting.",
        category: "tools", tech_stack: ["Elixir", "Phoenix LiveView"],
        github_repos: [],
        internal_path: "/collage-maker", external_url: nil, pixel_art_path: "/images/museum/collage-maker.png",
        emoji: "🖼️", color: "#a855f7", sort_order: 30, visible: true, inserted_at: now, updated_at: now},

      %{slug: "mta-bus-tracker", title: "MTA Bus Tracker", tagline: "Real-time MTA bus and train tracking on an interactive map",
        description: "Live tracking of MTA buses and trains on interactive Leaflet maps.\nSee real-time vehicle positions, route lines, and stop information\nfor New York City's transit system.",
        category: "maps", tech_stack: ["Elixir", "Phoenix LiveView", "Leaflet.js"],
        github_repos: [],
        internal_path: "/mta-bus-map", external_url: nil, pixel_art_path: "/images/museum/mta-bus-tracker.png",
        emoji: "🚌", color: "#0052a5", sort_order: 31, visible: true, inserted_at: now, updated_at: now}
    ]

    repo().insert_all("museum_projects", projects)
  end

  def down do
    execute("DELETE FROM museum_projects")
  end
end
