require 'nokogiri'
require 'open-uri'

module Sims
  class SthsPage
  	def initialize(doc_url)
      @doc = Nokogiri::HTML(open(doc_url))
      @body_node = safe_get_body_node
      @head_node = safe_get_head_node
    end

    private
     
    def safe_get_body_node
    	body_node = @doc.root.children.find{ |node| node.name == "body" }
      return body_node unless body_node.nil?
      raise ArgumentError, "Could not find Body Node in Game Document"
    end

    def safe_get_head_node
      head_node = @doc.root.children.find{ |node| node.name == "head" }
      return head_node unless head_node.nil?
      raise ArgumentError, "Could not find Head Node in Game Document"
    end
  end
end
