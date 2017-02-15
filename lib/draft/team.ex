defmodule Draft.Team.Supervisor do
	use Supervisor
	require Logger

	def start_link do
		Supervisor.start_link(__MODULE__, [], name: __MODULE__)
	end

	def create_team(team_name, draft_name) do
		Supervisor.start_child(__MODULE__, [{team_name, draft_name}])
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

	def start_link({team_name, draft_name}) do
		GenServer.start_link(__MODULE__, {team_name, draft_name}, name: via_tuple(team_name))
	end

	def get_pid(draft_name) do
		case Registry.lookup(:registry, {__MODULE__, draft_name}) do
			[] -> :empty
			[{ pid, _}] -> pid
		end
	end

	defp via_tuple(name) do
		{:via, Registry, {:registry, {__MODULE__, name}}}
	end

	def notify_on_clock(team_pid) do
		GenServer.call(team_pid, :on_clock)
	end

	#####
	#	Genserver Callbacks

	def init({team_name, draft_name} = options) do
		Logger.debug "in #{__MODULE__}.init options is #{inspect options}"
		{:ok, {team_name, draft_name}}
	end

	def handle_call(:draft_started, _from, {team_name, _ } = state) do
		Logger.debug("draft_started recieved for #{team_name}")
		{:reply, :ok, state}
	end

	def handle_call(:on_clock, _from, {team_name, _ } = state) do
		Logger.debug("#{team_name} says: I'm up!")
		{:reply, :ok, state}
	end
end