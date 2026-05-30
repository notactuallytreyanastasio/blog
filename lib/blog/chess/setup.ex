defmodule Blog.Chess.Setup do
  @moduledoc """
  Builds the initial plane and game state for a chess9 game.

  Each of the 9 boards (arranged in a 3x3 super-grid) receives a standard
  chess army. Within each board, local rank 0 (top, smaller gy) holds black
  pieces and local rank 7 (bottom, larger gy) holds white pieces.

  White advances toward gy=0; black advances toward gy=23.
  """

  alias Blog.Chess.{Plane, Piece, State, Ledger, Pieces}
  alias Blog.Chess, as: C

  @back_rank Pieces.back_rank()

  @doc """
  Returns the initial 576-element plane tuple with all 9 boards fully set up.

  Each board receives:
  - Black back rank at local rank 0 (gy = board_origin_y + 0)
  - Black pawns at local rank 1 (gy = board_origin_y + 1)
  - White pawns at local rank 6 (gy = board_origin_y + 6)
  - White back rank at local rank 7 (gy = board_origin_y + 7)
  """
  @spec initial_plane() :: C.plane()
  def initial_plane do
    writes =
      for board <- 0..8,
          file <- 0..7 do
        bx = rem(board, 3)
        by = div(board, 3)
        gx = bx * 8 + file
        gy0 = by * 8
        back_type = Enum.at(@back_rank, file)

        [
          {{gx, gy0 + 0}, Piece.new(back_type, :black)},
          {{gx, gy0 + 1}, Piece.new(:pawn, :black)},
          {{gx, gy0 + 6}, Piece.new(:pawn, :white)},
          {{gx, gy0 + 7}, Piece.new(back_type, :white)}
        ]
      end

    Plane.with_pieces(Plane.empty_plane(), List.flatten(writes))
  end

  @doc """
  Returns the initial `Blog.Chess.State` for a new chess9 game.

  - `to_move` is `:white`
  - `ledger` is empty (no crossing credits)
  - `status` is a 9-element tuple of `:active`
  - `clocks` is a 9-element tuple of `0`
  - `en_passant` is `nil`
  - `ply` is `0`
  """
  @spec initial_state() :: State.t()
  def initial_state do
    %State{
      plane: initial_plane(),
      to_move: :white,
      ledger: Ledger.empty_ledger(),
      status: :erlang.make_tuple(9, :active),
      clocks: :erlang.make_tuple(9, 0),
      en_passant: nil,
      ply: 0
    }
  end
end
