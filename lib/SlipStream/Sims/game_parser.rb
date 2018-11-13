require 'nokogiri'
require 'open-uri'

module Sims
  class GameParser
    SAMPLE_URL = "http://simulationhockey.com/games/smjhl/S44/Preseason/SMJHL-PRE-17.html"
    SLIP = "Slip McScruff"

    PLAY_BY_PLAY_CLASS = "STHSGame_PlayByPlayPeriod"

    def initialize(game_url)
      @doc = Nokogiri::HTML(open(game_url))
    end

    def get_player_pbp(player_name)
      search_pbp(player_name)
    end

    def get_slip_pbp
      get_player_pbp(SLIP)
    end

    private

    # @return [Hash<String, Array<String>] Hash from Period to the relevant plays from that period.
    #   Sample Key: "1st period"
    #   Sample Play: "\n0:01 of 1st period - Steven Moyer wins face-off versus Xena in neutral zone. "
    def search_pbp(search_pattern)
      body_node = safe_get_body_node
      pbp_starts = safe_get_pbp_starts(body_node)
      pbp_hash = Hash.new
      pbp_starts.each do |pbp_start_node|
        relevant_plays = process_pbp_period(pbp_start_node, search_pattern)
        pbp_hash[pbp_start_node.text] = relevant_plays
      end
      pbp_hash
    end

    def safe_get_body_node
      body_node = @doc.root.children.find{ |node| node.name == "body" }
      return body_node unless body_node.nil?
      raise ArgumentError, "Could not find Body Node in Game Document"
    end

    def safe_get_pbp_starts(body_node)
      pbp_starts = body_node.children.find_all{ |node| get_node_class(node) == PLAY_BY_PLAY_CLASS }
      return pbp_starts unless pbp_starts.empty?
      raise ArgumentError, "Could not find Play by Play Starts in Game Document"
    end

    def process_pbp_period(pbp_start_node, search_pattern)
      relevant_plays = []
      current_node = pbp_start_node.next_sibling
      while not_pbp_end?(current_node)
        relevant_play = scan_node(current_node, search_pattern)
        relevant_plays << relevant_play unless relevant_play.nil?
        current_node = current_node.next_sibling
      end
      relevant_plays
    end

    # If the node has a class, it marks the start of the next section 
    # Should only be the next pbp period or the full pbp start, but kept the logic robust
    def not_pbp_end?(node)
      get_node_class(node).nil?
    end

    def get_node_class(node)
      node.get_attribute("class")
    end

    def scan_node(node, search_pattern)
      search_regexp = Regexp.new search_pattern
      search_regexp =~ node.text ?
        node.text : 
        nil
    end

  end
end
