require 'SlipStream/sims/sths_page'
require 'SlipStream/sims/game_parser'

module Sims
	class SeasonParser < SthsPage
	  SAMPLE_URL = "http://simulationhockey.com/games/smjhl/S44/Season/SMJHL-ProTeamSchedule.html"
	  STL = "St.LouisScarecrows"

	  SCHEDULE_SUFFIX = "ProTeamSchedule.html"
	  TEAM_SECTION_PREFIX = "STHS_JS_Team_"
	  DIRECT_LINK_TEXT = "Game Direct Link"

	  # Currently only parses Juniors, need to add support for the SHL Suffix
	  # Schedule pages for the SMJHL look like the SAMPLE_URL above.  The Preseason will have PRE between 
	  # 	the league abbreviation and Schedule Suffix.
	  def initialize(schedule_url)
	  	super(schedule_url)
	  	raise ArgumentError, "URL must be a Schedule Page" unless schedule_url.end_with?(SCHEDULE_SUFFIX)

	  	# Taking the basename will give everything after the "/" like "SMJHL-ProTeamSchedule.html".
	  	# By scrubbing it from the base_url, we make sure we're building the gamelinks for the proper season
	  	full_pagename = File.basename(schedule_url)
	  	@base_url = schedule_url.gsub(full_pagename, "")
	  	@games = Hash.new
	  end

	  def get_games_for_team(team_id)
	  	@games[team_id] ||= pull_games_for_team(team_id)
	  end

	  # Convenience method to pull the games for the best team in the league
	  def get_STL_games
	  	get_games_for_team(STL)
	  end

	  private

	  def pull_games_for_team(team_id)
	  	team_section_node = safe_get_team_section_node(team_id)
	  	game_table_node = safe_get_game_table_node(team_section_node)
	  	games = game_table_node.children.map do |child_node|
	  		if is_table_row?(child_node)
	  			game_link_node = safe_get_game_link_node(child_node)
	  			next if game_link_node.nil?
	  			game_link = build_game_link(game_link_node)
	  			Sims::GameParser.new(game_link)
	  		end
	  	end.compact
	  	games
	  end

	  def safe_get_team_section_node(team_id)
	  	full_team_id = TEAM_SECTION_PREFIX + team_id
	  	team_section_node = @body_node.children.find{ |node| node.get_attribute("id") == full_team_id}
	  	return team_section_node unless team_section_node.nil?
	  	raise ArgumentError, "Could not find Team Section in Schedule Document"
	  end

	  def safe_get_game_table_node(team_section_node)
	  	game_table_node = team_section_node.children.find{ |node| node.name == "table" }
	  	return game_table_node unless game_table_node.nil?
	  	raise ArgumentError, "Could not find Game Table in Team Section of Schedule Document"
	  end

	  def safe_get_game_link_node(row_node)
	  	# Each child node is a "td" node wrapper with a direct child that has the actual content
	  	unwrapped_children = row_node.children.map do |td_wrapper|
	  		raise ArgumentError, "Table Row had non-td child" unless td_wrapper.name == "td"
	  		raise ArgumentError, "td Node had multiple children" if td_wrapper.children.count > 1
	  		td_wrapper.children.first
	  	end.compact
	  	link_node = unwrapped_children.find{ |node| node.text == DIRECT_LINK_TEXT }

	  	puts "Missing Link, game might not have been played" if link_node.nil?

	  	link_node
	  end

	  def build_game_link(game_link_node)
	  	game_href = game_link_node.get_attribute("href")
	  	@base_url + game_href
	  end

	  def is_table_row?(node)
	  	node.name == "tr"
	  end

	end
end
