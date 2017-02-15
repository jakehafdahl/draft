require Logger

defmodule Draft.Lobby do
	use GenServer

	def start_link({draft_name, _, _} = args) do
		Logger.debug "in #{__MODULE__}.start_link with draft_name #{draft_name}"
    	GenServer.start_link(__MODULE__, args, name: via_tuple(draft_name))
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

	def create_draft(draft_name, num_teams, options) do
		Draft.Lobby.Supervisor.create_draft(draft_name, num_teams, options)
	end

	def join_draft(draft_pid, team_name, team_pid) do
		GenServer.call(draft_pid, {:join_draft, team_name, team_pid})
	end

	#####
	#	Genserver Callbacks

	defp try_get_then_default(options, key) do
		case Keyword.fetch(options, key) do
			{:ok, value} -> value
			:error	-> Application.get_env(:draft, key)
		end
	end

	def init({draft_name, num_teams, options}) do
		Logger.debug "in #{__MODULE__}.init with draft_name #{draft_name}, num_teams #{num_teams}, options #{inspect options}"

		scoring_settings = try_get_then_default(options, :scoring_settings)
		draftable_players = try_get_then_default(options, :players)
		roster_settings = try_get_then_default(options, :roster_settings)

		{:ok, %Draft.State{name: draft_name, max_teams: num_teams, 
							teams: [], scoring_settings: scoring_settings, 
							players: draftable_players, roster_settings: roster_settings}}
	end

	def handle_call({:join_draft, _, _}, _from, %Draft.State{max_teams: max_teams, teams: teams} = state) 
		when length(teams) == max_teams, do: {:reply, :full, state}

	def handle_call({:join_draft, team_name, team_pid}, _from, state) do
		{:reply, :ok, Draft.State.add_team(state, team_name, team_pid)}
	end

	def handle_cast(:start_draft, %Draft.State{teams: teams} = state) do
		# Notify teams that the draft has started
		teams |> Enum.each(fn {_, pid, _} ->
			:ok = GenServer.call(pid, :draft_started)
		end)

		{_, pid, _} = teams |> Enum.find(fn {_, _,index} -> index == 0 end)
		Draft.Team.notify_on_clock(pid)

		{:noreply, Draft.State.set_status(state, "Started")}
	end
end

defmodule Draft.Lobby.Supervisor do
	use Supervisor

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