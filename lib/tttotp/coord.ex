defmodule Tttotp.Coord do
  alias __MODULE__

  @enforce_keys [:x, :y]
  defstruct [:x, :y]

  def new(x, y) when is_integer(x) and x in (1..3) and
                     is_integer(y) and y in (1..3) do
    {:ok, %Coord{x: x, y: y}}
  end

  def new(_, _), do: {:error, :invalid_coordinates}

end
