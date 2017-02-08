defmodule Draft.Server.Supervisor do
	use Supervisor
	require Logger

	def start_link(initial_state) do
		result = {:ok, pid} = Supervisor.start_link(__MODULE__, [],[])
		start_workers(pid, initial_state)
		result
	end

	def start_workers(sup, initial_state) do
		Supervisor.start_child(sup, worker(Draft.Server, [initial_state]))
	end

	def init(_) do
		supervise [], strategy: :one_for_one
	end
end

defmodule Draft.Server do
	use GenServer
	require Logger


	def start_link({draft_name, _, _} = args) do
		Logger.debug "in #{__MODULE__}.start_link with draft_name #{draft_name}"
    	GenServer.start_link(__MODULE__, args, name: via_tuple(draft_name))
	end

	def create_draft(draft_name, num_teams, options) do
		{:ok, _pid} = Draft.Server.Supervisor.start_link({draft_name, num_teams, options})
		via_tuple(draft_name)
	end

	def create_team_for_draft(team_name, draft_tuple) do
		Draft.Team.Server.create_team(team_name, draft_tuple)
	end

	def via_tuple(draft_name) do
		{:via, :gproc, {:n, :l, {:draft_room, draft_name}}}
	end

	#####
	#	Genserver Callbacks

	def init({draft_name, num_teams, options}) do
		Logger.debug "in #{__MODULE__}.init with draft_name #{draft_name}, num_teams #{num_teams}, options #{inspect options}"
		teams = 1..num_teams
				|> Enum.map(fn n -> Draft.Server.create_team_for_draft("Team #{n}", via_tuple(draft_name)) end)
		{:ok, {draft_name, {num_teams, options}, teams}}
	end
end