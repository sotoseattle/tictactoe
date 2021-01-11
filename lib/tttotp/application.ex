defmodule Tttotp.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Registry.Game},
      Tttotp.GameSupervisor
    ]

    :ets.new(:game_state, [:public, :named_table])

    opts = [strategy: :one_for_one, name: Tttotp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
