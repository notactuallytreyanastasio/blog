# Assay / Dialyzer ignore rules.
#
# Each entry is a string (substring match), a regex, or a map with
# :file / :message / :line / :code keys (all keys AND together).
#
# Keep this list small and well-justified. Every entry should explain WHY the
# warning is a false positive rather than a real defect.
[
  # MapSet is an opaque type defined in another module. When a MapSet is
  # threaded through this module's private BFS/DFS recursion helpers and queried
  # with MapSet.member?/2, Dialyzer's opaqueness checker can't see through the
  # opaque term and reports "opaque"/"contract opaque" violations on the
  # member?/put calls and the helper specs. The code uses only MapSet's public
  # API (new/member?/put), so these are a known Dialyzer limitation, not bugs.
  # Scoped to MapSet-related messages in this one file so a genuine opaque issue
  # elsewhere in it would still surface.
  %{file: "lib/blog/smart_steps/designer_logic.ex", message: ~r/MapSet/}
]
