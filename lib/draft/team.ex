defmodule Draft.Team.Supervisor do
	use Supervisor


	def start_link(options) do
		Supervisor.start_link(__MODULE__, [], options)
	end

	def init(_) do
		children = [
			worker(Draft.Team.Server, [], []) 
		]
		supervise children, strategy: :one_for_one
	end
end

defmodule Draft.Team.Server do
	use GenServer
	require Logger

	def start_link({team_name, draft_pid}) do
		{:ok, team_pid } = result = GenServer.start_link(__MODULE__, [{team_name, draft_pid}])
		Logger.debug "client pid #{inspect team_pid} joining draft"
		result
	end

	def get_team_name(tid) do
		GenServer.call(tid, :get_team_name)
	end

	#####
	#	Genserver Callbacks

	def handle_call(:get_team_name, _from, {team_name, _, _} = state) do
		{:reply, team_name, state}
	end

	def init({team_name, draft_pid}) do
		{:ok, {team_name, draft_pid, %{}}}
	end
end