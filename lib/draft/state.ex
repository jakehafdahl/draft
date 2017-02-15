defmodule Draft.State do
	defstruct name: "", max_teams: 12, teams: [], players: {[],[]}, scoring_settings: [],
			status: "Created", roster_settings: [], pick_number: 1, draft_settings: []

	# def available_players(%Draft.State{players: {available_players, _}}) do
	# 	available_players
	# end

	# def all_players(%Draft.State{players: {available_players, taken_players}}) do
	# 	[available_players | taken_players]
	# end

	# def take_player(%Draft.State{players: {available_players, taken_players}, teams: teams} = state, {team_name, roster, watch_list}, player) do
	# 	%Draft.State{ state | players: {new_available, new_taken}}
	# end

	def add_team(%Draft.State{teams: teams} = state, team_name, team_pid) do
		%Draft.State{state | teams: [{team_name, team_pid, length(teams)} | teams]}
	end

	def set_status(state, status) do
		%Draft.State{ state | status: status}
	end
end