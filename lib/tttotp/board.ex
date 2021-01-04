defmodule Tttotp.Board do
  alias Tttotp.Coord

  @c11 %Coord{x: 1, y: 1}
  @c12 %Coord{x: 1, y: 2}
  @c13 %Coord{x: 1, y: 3}
  @c21 %Coord{x: 2, y: 1}
  @c22 %Coord{x: 2, y: 2}
  @c23 %Coord{x: 2, y: 3}
  @c31 %Coord{x: 3, y: 1}
  @c32 %Coord{x: 3, y: 2}
  @c33 %Coord{x: 3, y: 3}

  def new do
    for x <- (1..3), y <- (1..3) do
      {:ok, c} = Coord.new(x, y)
      {c, nil}
    end |> Map.new()
  end

  def move(board, %Coord{} = coord, token) do
    case valid_move?(board, coord) do
      true ->
        {:ok, %{board | coord => token}}
      false ->
        {:error, :square_already_taken}
    end
  end

  def win_status(board, player) do
    token_coords = get_all_squares(board, player.token)
    case win?(token_coords) do
      true  -> :win
      false -> check_tie(board)
    end
  end

  defp check_tie(board) do
    case count_occupied_spaces(board) do
      9 -> :tie
      _ -> :go_on
    end
  end

  def count_occupied_spaces(board) do
    board |> Map.values |> Enum.count(&(&1!=nil))
  end

  defp get_all_squares(board, token) do
    board
    |> Enum.filter(fn {_k, v} -> v == token end)
    |> Enum.map(&elem(&1, 0))
  end

  defp win?([@c11, @c12, @c13]), do: true
  defp win?([@c21, @c22, @c23]), do: true
  defp win?([@c31, @c32, @c33]), do: true
  defp win?([@c11, @c21, @c31]), do: true
  defp win?([@c12, @c22, @c32]), do: true
  defp win?([@c13, @c23, @c33]), do: true
  defp win?([@c11, @c22, @c33]), do: true
  defp win?([@c13, @c22, @c31]), do: true
  defp win?(_coords), do: false

  defp valid_move?(board, coord), do: board[coord] == nil
end
