defmodule Tttotp.Rules do
  alias __MODULE__
  defstruct state: :initialized

  def new, do: %Rules{}

  # Start game with 2 players
  def check(%Rules{state: :initialized} = rules, :add_player) do
    {:ok, %{rules | state: :player1_turn}}
  end

  # Alternating turns
  def check(%Rules{state: :player1_turn} = rules, {:move, player}) do
    case player do
      :player1 -> {:ok, %{rules | state: :player2_turn}}
      :player2 -> {:error, :not_your_turn}
    end
  end

  def check(%Rules{state: :player2_turn} = rules, {:move, player}) do
    case player do
      :player2 -> {:ok, %{rules | state: :player1_turn}}
      :player1 -> {:error, :not_your_turn}
    end
  end

  # Ending conditions
  def check(%Rules{state: :player1_turn} = rules, {:win_check, wino}) do
    case wino do
      :win -> {:ok, %{rules | state: :game_over}}
      :tie -> {:ok, %{rules | state: :game_over}}
      _ -> {:ok, rules}
    end
  end

  def check(%Rules{state: :player2_turn} = rules, {:win_check, wino}) do
    case wino do
      :win -> {:ok, %{rules | state: :game_over}}
      :tie -> {:ok, %{rules | state: :game_over}}
      _ -> {:ok, rules}
    end
  end

  def check(_rules, _action), do: {:error, :state_machine}
end
