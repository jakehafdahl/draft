defmodule Draft.Server do
	use GenServer
	require Logger


	def start_link(draft_name) do
    	GenServer.start_link(__MODULE__, [draft_name])
	end

	def join_draft(draft_pid, client_pid) do
		Logger.debug "client pid #{inspect client_pid} joining draft #{inspect draft_pid}"
		team_name = Draft.Team.Server.get_team_name(client_pid)
		GenServer.cast(draft_pid, {:join_draft, client_pid, team_name})
	end

	#####
	#	Genserver Callbacks

	def handle_cast({:join_draft, client_pid, team_name}, %{teams: teams } = state) do
		# Do something to setup a transport between the client and the draft
		# For now just return the pid of the draft and set up convenience calls
		{:noreply, %{state | teams: [{team_name, client_pid} | teams]}}
	end

	def init(draft_name) do
		{:ok, %{ draft_name: draft_name, teams: []}}
	end
end