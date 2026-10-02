#!/bin/bash
# Edits the Elixir that be-elixir generated for this library, one way at a
# time, and asks Dialyzer about each copy. Prints only the spec warnings.
#
#   temper build -b elixir -w .
#   ./swaps.sh path/to/temper/be-elixir/src/commonTest/resources/lang/temper/be/elixir/dialyze.exs /tmp/temper.plt
#
# Copies go to ./swaps/<name>; each Dialyzer report to ./swaps/<name>.out.
set -e
here=$(cd "$(dirname "$0")" && pwd)
dial=$1; plt=$2
gen=$here/temper.out/elixir
CN='Temper.Classes.Counter.t()'; SQ='Temper.Classes.Square.t()'

# Counter's constructor claims to make a Square
CTOR_SQ='s/\@spec new\(\) :: \Q'$CN'\E/\@spec new() :: '$SQ'/'
# Counter's bump claims to want a Square
BUMP_SQ='s/\@spec bump\(\Q'$CN'\E\)/\@spec bump('$SQ')/'
# Tally's constructor claims to make an actor of another class
TALLY_OTHER='s/\@spec new\(\) :: Temper\.Classes\.Tally\.t\(\)/\@spec new() :: %TemperCore.Actor{class: Temper.Classes.Counter, id: reference()}/'
# take out fresh(), the only caller
NO_FRESH='s/  \@spec fresh\(\).*?\n  end\n//s'
# constructors as they were before: the ref comes back from Heap.new/2 ...
HEAP_NEW='s/this = %TemperCore.Ref\{class: (Temper\.Classes\.\w+), id: make_ref\(\)\}\n\s*TemperCore\.Heap\.init\(this, /this = TemperCore.Heap.new($1, /g'
# ... and the actor from Actor.start/2
ACTOR_START='s/%TemperCore\.Actor\{class: Temper\.Classes\.Tally, id: TemperCore\.Actor\.start_id\((.*?)\n    end\)\}/TemperCore.Actor.start($1\n    end)/s'

swap() {
  name=$1; shift
  d=$here/swaps/$name
  rm -rf "$d"; mkdir -p "$d"; cp -R "$gen/classes" "$gen/temper-core" "$d/"; rm -rf "$d"/*/_build
  for e in "$@"; do perl -0pi -e "$e" "$d/classes/lib/temper_main.ex"; done
  echo "== $name"
  elixir "$dial" "$plt" "$d/classes" > "$d.out" 2>&1 || true
  grep -E '^SPEC' "$d.out"
}
swap as-generated
swap ctor-says-square            "$CTOR_SQ"
swap bump-wants-square           "$BUMP_SQ"
swap no-fresh_ctor-says-square   "$NO_FRESH" "$CTOR_SQ"
swap no-fresh_bump-wants-square  "$NO_FRESH" "$BUMP_SQ"
swap tally-says-other            "$TALLY_OTHER"
swap heap-new                    "$HEAP_NEW" "$ACTOR_START"
swap heap-new_ctor-says-square   "$HEAP_NEW" "$CTOR_SQ"
swap heap-new_bump-wants-square  "$HEAP_NEW" "$BUMP_SQ"
swap heap-new_no-fresh_ctor-says-square  "$HEAP_NEW" "$NO_FRESH" "$CTOR_SQ"
swap heap-new_no-fresh_bump-wants-square "$HEAP_NEW" "$NO_FRESH" "$BUMP_SQ"
swap actor-start_tally-says-other "$ACTOR_START" "$TALLY_OTHER"
