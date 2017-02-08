defmodule Draft.Orchestration.Supervisor do
	use Supervisor

	def start_link do
		Supervisor.start_link(__MODULE__, [],[])
	end

	def init(_) do
		children = [
			worker(Draft.Orchestration.Server, [])
		]
		supervise children, strategy: :one_for_one
	end
end

defmodule Draft.Orchestration.Server do
	use GenServer

	def start_link do
		GenServer.start_link(__MODULE__, [], name: :draft_orchestrator)
	end

	def start_draft(draft_name, num_teams, options) do
		draft_tuple = {:via, _, _} = Draft.Server.create_draft(draft_name, num_teams, options)
		GenServer.call(:draft_orchestrator, {:add_draft, draft_tuple})
	end

	def handle_call({:add_draft, draft_tuple}, _from, drafts) do
		{:reply, :ok, [draft_tuple | drafts]}
	end

	def init(_) do
		{:ok, []}
	end
end