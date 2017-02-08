defmodule Draft.Team.Supervisor do
	use Supervisor
	require Logger

	def start_link(options) do
		Supervisor.start_link(__MODULE__, options,[])
	end

	def init(options) do
		Logger.debug "in #{__MODULE__}.init options is #{inspect options}"
		children = [
			worker(Draft.Team.Server, [options]) 
		]
		supervise children, strategy: :one_for_one
	end
end

defmodule Draft.Team.Server do
	use GenServer
	require Logger

	def start_link({team_name, draft_tuple} = options) do
		Logger.debug "in #{__MODULE__}.start_link options is #{inspect options}"
		GenServer.start_link(__MODULE__, {team_name, draft_tuple}, name: via_tuple(team_name))
	end

	def create_team(team_name, draft_tuple) do
		{:ok, _pid} = Draft.Team.Supervisor.start_link({team_name, draft_tuple})
		Logger.debug "in #{__MODULE__}.create_team returned ok for #{team_name}"
		via_tuple(team_name)
	end

	def get_team_info(team_name) do
		GenServer.call(via_tuple(team_name), :get_team_name)
	end

	def via_tuple(league_name) do
		{:via, :gproc, {:n, :l, {:draft_room, league_name}}}
	end

	#####
	#	Genserver Callbacks

	def handle_call(:get_team_name, _from, {team_name, _} = state) do
		{:reply, team_name, state}
	end

	def init({team_name, draft_tuple} = options) do
		Logger.debug "in #{__MODULE__}.init options is #{inspect options}"
		{:ok, team_name, draft_tuple}
	end
end