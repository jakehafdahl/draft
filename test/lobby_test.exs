defmodule LobbyTest do
	use ExUnit.Case
  	doctest Draft.Lobby

  	test "draft init uses passed in options for scoring_settings" do
  		{:ok, %Draft.State{ scoring_settings: actual }} = Draft.Lobby.init({"test", 1, [scoring_settings: :foo]})
  		assert actual == :foo
  	end

  	test "draft init uses passed in options for roster_settings" do
  		{:ok, %Draft.State{ roster_settings: actual }} = Draft.Lobby.init({"test", 1, [roster_settings: :foo]})
  		assert actual == :foo
  	end

  	test "draft init uses passed in options for players" do
  		{:ok, %Draft.State{ players: actual }} = Draft.Lobby.init({"test", 1, [players: :foo]})
  		assert actual == :foo
  	end

  	test "calling join_draft adds a team to the draft" do
  		{:reply, :ok, %Draft.State{teams: [{team_name, team_pid, team_index}]}} = 
  			Draft.Lobby.handle_call({:join_draft, "test", :fake_pid}, :fake_pid, %Draft.State{max_teams: 2, teams: []})
  		assert team_name == "test"
  		assert team_pid == :fake_pid
  		assert team_index == 0
  	end

  	test "calling join_draft returns full when draft is has max teams" do
  		{:reply, status, _} = Draft.Lobby.handle_call({:join_draft, "", :a}, :a, %Draft.State{max_teams: 2, teams: [1,2]})
  		assert status == :full
  	end

  	test "calling start_draft sets the draft status to 'Started'" do
  		state = %Draft.State{status: before_status} = %Draft.State{}
  		assert before_status == "Created"

  		{:noreply, %Draft.State{status: after_status}} = Draft.Lobby.handle_cast(:start_draft, state)
  		assert after_status == "Started"

  	end
end