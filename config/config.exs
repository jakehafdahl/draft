# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#

rush_yards_scoring = ["QB", "RB", "WR", "TE"] 
				|> Enum.map(&(%{position: &1, field: "rush_yards", required_amt: 10, points_for: 1, continuous: true}))

rush_td_scoring = ["QB", "RB", "WR", "TE"] 
				|> Enum.map(&(%{position: &1, field: "rush_td", required_amt: 1, points_for: 6, continuous: true}))

pass_yard_scoring = ["QB", "RB", "WR", "TE"] 
				|> Enum.map(&(%{position: &1, field: "pass_yards", required_amt: 20, points_for: 1, continuous: true}))

pass_td_scoring = ["QB", "RB", "WR", "TE"] 
				|> Enum.map(&(%{position: &1, field: "pass_td", required_amt: 1, points_for: 4, continuous: true}))

rec_yards_scoring = ["QB", "RB", "WR", "TE"] 
				|> Enum.map(&(%{position: &1, field: "rec_yards", required_amt: 10, points_for: 1, continuous: true}))

rec_td_scoring = ["QB", "RB", "WR", "TE"] 
				|> Enum.map(&(%{position: &1, field: "rec_td", required_amt: 1, points_for: 6, continuous: true}))

scoring_settings = [rush_yards_scoring, rush_td_scoring, pass_yard_scoring, pass_td_scoring, rec_yards_scoring, rec_td_scoring]
	|> Enum.reduce([],fn x, acc ->
		[x | acc] end)

config :draft, 
	players: [
		{"Adrian Peterson", "RB", 312},
		{"Aaron Rdogers", "QB", 412},
		{"Calvin Johnson", "WR", 342},
		{"Rob Gronkowski", "TE", 242}
	],
	scoring_settings: scoring_settings,
	roster_settings: [
		{"QB", ["QB"]},
		{"RB1", ["RB"]},
		{"RB2", ["RB"]},
		{"WR1", ["WR"]},
		{"WR2", ["WR"]},
		{"FLEX", ["RB", "WR", "TE"]},
		{"TE", ["TE"]},
		{"K", ["K"]},
		{"DST", ["DST"]},
		{"BENCH1", ["QB", "RB", "WR", "TE", "K", "DST"]},
		{"BENCH2", ["QB", "RB", "WR", "TE", "K", "DST"]},
		{"BENCH3", ["QB", "RB", "WR", "TE", "K", "DST"]},
		{"BENCH4", ["QB", "RB", "WR", "TE", "K", "DST"]},
		{"BENCH5", ["QB", "RB", "WR", "TE", "K", "DST"]},
		{"BENCH6", ["QB", "RB", "WR", "TE", "K", "DST"]},
		{"BENCH7", ["QB", "RB", "WR", "TE", "K", "DST"]}
	]


#
# And access this configuration in your application as:
#
#     Application.get_env(:draft, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"
