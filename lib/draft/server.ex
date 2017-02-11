defmodule Draft.Lobby.Supervisor do
	use Supervisor
	require Logger

	def start_link do
		Supervisor.start_link(__MODULE__, [], name: __MODULE__)
	end

	def create_draft(draft_name, num_teams, options) do
		Supervisor.start_child(__MODULE__, [{draft_name, num_teams, options}])
	end

	def init(_) do
		children = [
			supervisor(Draft.Lobby.SubSupervisor, [], restart: :transient)
		]

		supervise children, strategy: :simple_one_for_one
	end
end

defmodule Draft.Lobby.SubSupervisor do
	use Supervisor
	require Logger

	def start_link(args) do
		Supervisor.start_link(__MODULE__, [args])
	end

	def init(options) do
		Logger.debug "in #{__MODULE__}.init options is #{inspect options}"
		children = [
			worker(Draft.Lobby, options, restart: :transient)
		]

		supervise children, strategy: :one_for_one
	end
end

defmodule Draft.Lobby do
	use GenServer
	require Logger


	def start_link({draft_name, _, _} = args) do
		Logger.debug "in #{__MODULE__}.start_link with draft_name #{draft_name}"
    	GenServer.start_link(__MODULE__, args, name: via_tuple(draft_name))
	end

	def create_team_for_draft(draft_name, team_index, draft_tuple) do
		Draft.Team.Supervisor.create_team(draft_name, team_index, draft_tuple)
	end

	def via_tuple(draft_name) do
		{:via, :gproc, {:n, :l, {:draft_room, draft_name}}}
	end

	def join_draft(draft_via, team_via, team_name) do
		GenServer.call(draft_via, {:join_draft, team_via, team_name})
	end
	#####
	#	Genserver Callbacks
	def handle_call({:join_draft, _, _}, _, {_, {num_teams, _}, teams} = state) when length(teams) == num_teams, do: {:reply, :full, state}
	def handle_call({:join_draft, team_via, team_name}, _from, {draft_name, {num_teams, options}, teams}) do
		{:reply, :ok, {draft_name, {num_teams, options}, [ {team_name, team_via} | teams]}}
	end

	def init({draft_name, num_teams, options}) do
		Logger.debug "in #{__MODULE__}.init with draft_name #{draft_name}, num_teams #{num_teams}, options #{inspect options}"
		teams = []
		# 1..num_teams
		# 		|> Enum.map(fn n -> Draft.Lobby.create_team_for_draft(draft_name, n, via_tuple(draft_name)) end)
		{:ok, {draft_name, {num_teams, options}, teams}}
	end
end