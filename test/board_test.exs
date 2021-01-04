defmodule BoardTest do
  alias Tttotp.{Player, Board, Coord}
  use ExUnit.Case
  doctest Tttotp

  setup_all do
    {:ok, c11} = Coord.new(1, 1)
    {:ok, c12} = Coord.new(1, 2)
    {:ok, c13} = Coord.new(1, 3)
    {:ok, c21} = Coord.new(2, 1)
    {:ok, c22} = Coord.new(2, 2)
    {:ok, c23} = Coord.new(2, 3)
    {:ok, c31} = Coord.new(3, 1)
    {:ok, c32} = Coord.new(3, 2)
    {:ok, c33} = Coord.new(3, 3)
    {:ok, c11: c11, c12: c12, c13: c13,
          c21: c21, c22: c22, c23: c23,
          c31: c31, c32: c32, c33: c33}
  end

  test "win condition", state do
    p = Player.new("pepe", "x")
    b = Board.new
    {:ok, b} = Board.move(b, state[:c11], p.token)
    {:ok, b} = Board.move(b, state[:c22], p.token)
    {:ok, b} = Board.move(b, state[:c33], p.token)
    assert Tttotp.Board.win_status(b, p) == :win
  end

  test "tie condition", state do
    pp = Player.new("pepe", "x")
    pl = Player.new("lola", "-")
    b = Board.new
    {:ok, b} = Board.move(b, state[:c11], pp.token)
    {:ok, b} = Board.move(b, state[:c13], pp.token)
    {:ok, b} = Board.move(b, state[:c21], pp.token)
    {:ok, b} = Board.move(b, state[:c23], pp.token)
    {:ok, b} = Board.move(b, state[:c32], pp.token)
    {:ok, b} = Board.move(b, state[:c12], pl.token)
    {:ok, b} = Board.move(b, state[:c22], pl.token)
    {:ok, b} = Board.move(b, state[:c31], pl.token)
    {:ok, b} = Board.move(b, state[:c33], pl.token)
    assert Tttotp.Board.win_status(b, pl) == :tie
  end

  test "go_on condition", state do
    pp = Player.new("pepe", "X")
    pl = Player.new("lola", "-")
    b = Board.new
    {:ok, b} = Board.move(b, state[:c11], pp.token)
    {:ok, b} = Board.move(b, state[:c12], pl.token)
    {:ok, b} = Board.move(b, state[:c13], pp.token)
    {:ok, b} = Board.move(b, state[:c21], pp.token)
    {:ok, b} = Board.move(b, state[:c22], pl.token)
    {:ok, b} = Board.move(b, state[:c23], pp.token)
    {:ok, b} = Board.move(b, state[:c31], pl.token)
    {:ok, b} = Board.move(b, state[:c32], pp.token)
    assert Tttotp.Board.win_status(b, pl) == :go_on
  end
end
