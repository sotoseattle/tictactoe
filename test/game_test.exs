defmodule GameTest do
  alias Tttotp.Game
  use ExUnit.Case
  doctest Tttotp


  test "starts a game" do
    {:ok, game} = Game.start_link("pepe")
    assert :sys.get_state(game).rules.state == :initialized
  end

  test "adds a player to the game" do
    {:ok, game} = Game.start_link("pepe")
    Game.add_player(game, "lola")
    assert :sys.get_state(game).rules.state == :player1_turn
  end

  test "player 1 moves" do
    {:ok, game} = Game.start_link("pepe")
    Game.add_player(game, "lola")
    Game.move(game, :player1, 1, 1)
    state = :sys.get_state(game)

    assert state.rules.state == :player2_turn
  end

  test "wrong atomic player tries to moves" do
    {:ok, game} = Game.start_link("pepe")
    Game.add_player(game, "lola")
    Game.move(game, :player1, 1, 1)
    Game.move(game, :wrong_player, 1, 3)
    state = :sys.get_state(game)

    assert state.rules.state == :player2_turn
  end

  test "player 1 moves twice" do
    {:ok, game} = Game.start_link("pepe")
    Game.add_player(game, "lola")
    Game.move(game, :player1, 1, 1)
    Game.move(game, :player1, 1, 2)
    state = :sys.get_state(game)

    assert state.rules.state == :player2_turn
    assert state.board[%Tttotp.Coord{x: 1, y: 1}] != nil
    assert state.board[%Tttotp.Coord{x: 1, y: 2}] == nil
    assert state.winner == nil
  end

  test "player 2 wins" do
    {:ok, game} = Game.start_link("pepe")
    Game.add_player(game, "lola")
    Game.move(game, :player1, 1, 1)
    Game.move(game, :player2, 3, 1)
    Game.move(game, :player1, 1, 2)
    Game.move(game, :player2, 3, 2)
    Game.move(game, :player1, 2, 1)
    Game.move(game, :player2, 3, 3)
    state = :sys.get_state(game)

    assert state.rules.state == :game_over
    assert state.winner == "lola"
  end

  test "tie" do
    {:ok, game} = Game.start_link("pepe")
    Game.add_player(game, "lola")
    Game.move(game, :player1, 1, 1)
    Game.move(game, :player2, 1, 2)
    Game.move(game, :player1, 1, 3)
    Game.move(game, :player2, 2, 2)
    Game.move(game, :player1, 2, 1)
    Game.move(game, :player2, 3, 1)
    Game.move(game, :player1, 2, 3)
    Game.move(game, :player2, 3, 3)
    Game.move(game, :player1, 3, 2)
    state = :sys.get_state(game)

    assert state.rules.state == :game_over
    assert state.winner == "tie"
  end

end
