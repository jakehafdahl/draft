defmodule Draft do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      supervisor(Registry, [:unique, :registry]),
      supervisor(Draft.Orchestrator.Supervisor, []),
      supervisor(Draft.Lobby.Supervisor, []),
      supervisor(Draft.Team.Supervisor, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Draft.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
