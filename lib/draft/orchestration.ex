defmodule Draft.Orchestrator.Supervisor do
	use Supervisor

	def start_link do
		Supervisor.start_link(__MODULE__, [],[])
	end

	def init(_) do
		children = [
			worker(Draft.Orchestrator, [])
		]
		supervise children, strategy: :one_for_one
	end
end

defmodule Draft.Orchestrator do
	use GenServer

	def start_link do
		GenServer.start_link(__MODULE__, [], name: :draft_orchestrator)
	end

	def start_draft(draft_name, num_teams, options) do
		{:ok, _pid} = Draft.Lobby.create_draft(draft_name, num_teams, options)
		draft_pid = Draft.Lobby.get_pid(draft_name)
		GenServer.call(:draft_orchestrator, {:add_draft, draft_name, draft_pid})
	end

	def handle_call({:add_draft, draft_name, draft_pid}, _from, drafts) do
		{:reply, :ok, [{draft_name, draft_pid} | drafts]}
	end

	def init(_) do
		{:ok, []}
	end
end