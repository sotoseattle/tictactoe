defmodule Tttotp.Player do
  alias __MODULE__

  @enforce_keys [:name, :token]
  defstruct [:name, :token]

  def new(name, token) do
    %Player{name: name, token: token}
  end
end
