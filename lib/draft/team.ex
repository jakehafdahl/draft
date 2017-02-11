defmodule Draft.Team.Supervisor do
	use Supervisor
	require Logger

	def start_link do
		Supervisor.start_link(__MODULE__, [], name: __MODULE__)
	end

	def create_team(room_name, team_name) do
		Supervisor.start_child(__MODULE__, [{team_name, room_name, Draft.Lobby.via_tuple(room_name)}])
	end

	def init(_) do
		Logger.debug "in #{__MODULE__}.init"
		children = [
			worker(Draft.Team, [], restart: :transient)
		]
		supervise children, strategy: :simple_one_for_one
	end
end

defmodule Draft.Team do
	use GenServer
	require Logger

	def start_link({team_name, draft_name, draft_via} = options) do
		Logger.debug "in #{__MODULE__}.start_link options is #{inspect options}"
		GenServer.start_link(__MODULE__, {team_name, draft_name, draft_via}, name: via_tuple(draft_name, team_name))
	end

	def via_tuple(draft_name, team_name) do
		{:via, :gproc, {:n, :l, "#{draft_name}-#{team_name}"}}
	end

	#####
	#	Genserver Callbacks

	def handle_call(:get_team_name, _from, {team_name, _} = state) do
		{:reply, team_name, state}
	end

	def init({team_name, draft_name, draft_via} = options) do
		Logger.debug "in #{__MODULE__}.init options is #{inspect options}"
		{:ok, {team_name, {draft_name, draft_via}}}
	end
end