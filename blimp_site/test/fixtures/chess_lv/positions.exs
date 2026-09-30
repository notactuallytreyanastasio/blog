# Writes positions.txt, the Elixir's answers that test/chess_lv_test.blimp
# checks the Temper against. From the repository root:
#
#   args=(); for f in lib/blog/chess/chess.ex lib/blog/chess/types.ex lib/blog/chess/*.ex; do args+=(-r "$f"); done
#   elixir "${args[@]}" blimp_site/test/fixtures/chess_lv/positions.exs > blimp_site/test/fixtures/chess_lv/positions.txt
#
# It plays four games of Blog.Chess against itself, seeded, 620 plies at
# most, picking at random among the legal moves but preferring en passant,
# castling and promotion when there is one (80%), then captures and
# crossings (60%). From those it keeps the first position where each rule
# was used: en passant, both castles, a promotion, a promotion by crossing
# capture, a crossing, a mate for each side, a stalemate, a board drawn for
# insufficient material, one drawn by the ply cap, a check. Then the bot's
# one-ply root in one position.
alias Blog.Chess.{Setup, Legal, Reducer, Eval}
alias Blog.Chess, as: C

defmodule Enc do
  @digits "0123456789abcdefghijklmnopqrstuv"
  @types %{pawn: 1, knight: 2, bishop: 3, rook: 4, queen: 5, king: 6}
  @kinds %{normal: 0, double_pawn: 1, en_passant: 2, promotion: 3, castle_kingside: 4, castle_queenside: 5}
  def code(nil), do: 0
  def code(p), do: @types[p.type] + if(p.color == :black, do: 8, else: 0) + if(p.has_moved, do: 16, else: 0)
  def ptype(nil), do: 0
  def ptype(t), do: @types[t]
  def status(:active), do: 0
  def status({:check, :white}), do: 1
  def status({:check, :black}), do: 2
  def status({:checkmate, :white, _}), do: 3
  def status({:checkmate, :black, _}), do: 4
  def status(:stalemate), do: 5
  def status({:draw, :fifty_move}), do: 6
  def status({:draw, :insufficient_material}), do: 7

  def move(m) do
    {fx, fy} = m.from
    {tx, ty} = m.to
    "#{@kinds[m.kind]},#{fx},#{fy},#{tx},#{ty},#{code(m.captured)},#{if m.crossing, do: 1, else: 0},#{ptype(m.promote_to)}"
  end

  def state(s) do
    {epx, epy} = s.en_passant || {-1, -1}
    plane = for i <- 0..575, into: "", do: String.at(@digits, code(elem(s.plane, i)))
    ledger =
      for b <- 0..8, c <- [:white, :black], t <- [:pawn, :knight, :bishop, :rook, :queen] do
        Map.get(s.ledger, {b, c, t}, 0)
      end

    Enum.join(
      [
        plane,
        "#{if s.to_move == :white, do: 0, else: 1},#{epx},#{epy},#{s.ply}",
        Enum.map_join(0..8, ",", &status(elem(s.status, &1))),
        Enum.join(Tuple.to_list(s.clocks), ","),
        Enum.join(ledger, ",")
      ],
      " "
    )
  end

  # Every score is a whole number of 32nds; anything else would be a surprise.
  def score(f) do
    r = round(f * 32)
    if abs(f * 32 - r) > 1.0e-9, do: raise("not a 32nd: #{f}")
    r
  end
end

defmodule Game do
  def play(seed, max) do
    :rand.seed(:exsss, {seed, 7, 11})

    Enum.reduce_while(1..max, {Setup.initial_state(), []}, fn _, {s, acc} ->
      legal = if Blog.Chess.Scoring.game_over?(s.status), do: [], else: Legal.legal_moves(s)

      if legal == [] do
        {:halt, {s, acc}}
      else
        rare = Enum.filter(legal, &(&1.kind in [:en_passant, :castle_kingside, :castle_queenside, :promotion]))
        loud = Enum.filter(legal, &(&1.captured != nil or &1.crossing != nil or &1.kind != :normal))

        pick =
          cond do
            rare != [] and :rand.uniform() < 0.8 -> Enum.random(rare)
            loud != [] and :rand.uniform() < 0.6 -> Enum.random(loud)
            true -> Enum.random(legal)
          end

        next = Reducer.apply_unchecked(s, pick)
        {:cont, {next, [{s, legal, pick, next} | acc]}}
      end
    end)
    |> elem(1)
    |> Enum.reverse()
  end

  def tags({s, _legal, m, next}) do
    new = for i <- 0..8, elem(s.status, i) != elem(next.status, i), do: Enc.status(elem(next.status, i))

    [
      {m.kind == :en_passant, "ep"},
      {m.kind == :castle_kingside, "castle_k"},
      {m.kind == :castle_queenside, "castle_q"},
      {m.kind == :promotion and m.crossing == nil, "promo"},
      {m.kind == :promotion and m.crossing != nil, "cross_promo"},
      {m.kind == :normal and m.crossing != nil, "cross"},
      {3 in new, "mate_w"},
      {4 in new, "mate_b"},
      {5 in new, "stalemate"},
      {7 in new, "insufficient"},
      {6 in new, "fifty"},
      {1 in new or 2 in new, "check"}
    ]
    |> Enum.filter(&elem(&1, 0))
    |> Enum.map(&elem(&1, 1))
  end
end

games = for seed <- 2..5, do: {seed, Game.play(seed, 620)}

found =
  Enum.reduce(games, %{}, fn {seed, plies}, acc ->
    Enum.reduce(plies, acc, fn ply, acc ->
      Enum.reduce(Game.tags(ply), acc, fn t, acc -> Map.put_new(acc, t, {seed, ply}) end)
    end)
  end)

IO.puts("""
# Chess-9 positions from Blog.Chess on origin/main, for test/chess_lv_test.blimp,
# written by positions.exs next to this file.
#   S  a position: 576 piece digits (0-v: type + 8 black + 16 moved),
#      to_move,ep_x,ep_y,ply, 9 statuses, 9 clocks, 90 ledger counts
#   E  Eval.evaluate(s, to_move), evaluate(s, other), leaf_score(s, to_move), x32
#   L  how many Legal.legal_moves(s) and the sha256 of them, in order, as
#      kind,fx,fy,tx,ty,captured,crossing,promote_to joined by spaces
#   M  the move played   N  Reducer.apply_unchecked(s, move)
#   B/R  a position and Bot's one-ply root: index into legal_moves:score x32\
""")

for t <- ~w(ep castle_k castle_q promo cross_promo cross mate_w mate_b stalemate insufficient fifty check) do
  {seed, {s, legal, m, next}} = Map.fetch!(found, t)
  text = Enum.map_join(legal, " ", &Enc.move/1)
  sha = :crypto.hash(:sha256, text) |> Base.encode16(case: :lower)
  IO.puts("# #{t} (seed #{seed}, ply #{s.ply})")
  IO.puts("S #{Enc.state(s)}")
  IO.puts("E #{Enc.score(Eval.evaluate(s, s.to_move))} #{Enc.score(Eval.evaluate(s, C.opposite(s.to_move)))} #{Enc.score(Eval.leaf_score(s, s.to_move))}")
  IO.puts("L #{length(legal)} #{sha}")
  IO.puts("M #{Enc.move(m)}")
  IO.puts("N #{Enc.state(next)}")
end

# Bot.score_root/2 at depth 1 (it is private; this is its body): every legal
# move's shallow score, largest first, generated order among equals.
{_s, plies} = Enum.find(games, fn {seed, _} -> seed == 2 end)
{s, legal, _m, _next} = Enum.at(plies, 98)

root =
  legal
  |> Enum.with_index()
  |> Enum.map(fn {m, i} -> {i, Eval.evaluate(Reducer.apply_unchecked(s, m), s.to_move)} end)
  |> Enum.sort_by(fn {_i, sc} -> sc end, :desc)

IO.puts("# bot, one ply (seed 2, ply #{s.ply})")
IO.puts("B #{Enc.state(s)}")
IO.puts("R 1 #{Enum.map_join(root, " ", fn {i, sc} -> "#{i}:#{Enc.score(sc)}" end)}")
