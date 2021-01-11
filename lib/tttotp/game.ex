defmodule Tttotp.Game do
  alias Tttotp.{Player, Board, Coord, Rules}

  @timeout 12 * 60 * 60 *1000

  # use GenServer
  use GenServer, start: {__MODULE__, :start_link, []}, restart: :transient

  @players [:player1, :player2]

  # CLIENT INTERFACE FUNCTIONS

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, [name: via_tuple(name)])
  end

  def add_player(game, name) when is_binary(name) do
    GenServer.call(game, {:add_player, name})
  end
  def add_player(_g, _name), do: {:error, :invalid_name}

  def move(game, player, x, y) when player in @players do
    GenServer.call(game, {:move, player, x, y})
  end
  def move(_g, _p, _x, _y), do: {:error, :player_does_not_exist}

  # SERVER CALLBACKS

  def init(name) do
    state = case :ets.lookup(:game_state, name) do
      [] -> initialized_game(name)
      [{_k, game}] -> game
    end

    :ets.insert(:game_state, {name, state})
    {:ok, state, @timeout}
  end

  defp initialized_game(name) do
    %{player1: Player.new(name, "x"),
      player2: Player.new("n.a.", "o"),
      board: Board.new(),
      rules: Rules.new(),
      winner: nil}
  end

  def handle_call({:add_player, name}, _from, game) do
    with {:ok, rules} <- Rules.check(game.rules, :add_player)
    do
      game
      |> update_player2(name)
      |> update_rules(rules)
      |> reply(:ok)
    else
      error_msg -> {:reply, error_msg, game}
    end
  end

  def handle_call({:move, player, x, y}, _from, game) do
    with {:ok, rules}  <- Rules.check(game.rules, {:move, player}),
         {:ok, coord}  <- Coord.new(x, y),
         {:ok, board}  <- Board.move(game.board, coord, game[player].token),
         win_tag       <- Board.win_status(board, game[player]),
         {:ok, rules}  <- Rules.check(rules, {:win_check, win_tag})
    do
      game
      |> update_board(board)
      |> update_rules(rules)
      |> update_winner(win_tag, player)
      |> reply(:ok)
    else
      error_msg -> {:reply, error_msg, game}
    end
  end

  def handle_info(:timeout, game) do
    {:stop, {:shutdown, :timeout}, game}
  end

  def terminate({:shutdown, :timeout}, game) do
    :ets.delete(:game_state, game.player1.name)
    :ok
  end
  def terminate(_reason, _state), do: :ok

  def via_tuple(name), do:
    {:via, Registry, {Registry.Game, name}}

  defp update_rules(game, rules), do:
    %{game | rules: rules}

  defp reply(game, reply) do
    :ets.insert(:game_state, {game.player1.name, game})
    {:reply, reply, game, @timeout}
  end

  defp update_player2(game, name), do:
    put_in(game.player2.name, name)

  defp update_board(game, board), do:
    %{game | board: board}

  defp update_winner(game, :win, player), do:
    %{game | winner: game[player].name}
  defp update_winner(game, :tie, _playe), do:
    %{game | winner: "tie"}
  defp update_winner(game, _, _), do:
    game
end
