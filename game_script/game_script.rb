require 'nokogiri'
require 'open-uri'

SLIP = "Slip McScruff"

doc = Nokogiri::HTML(open("http://simulationhockey.com/games/smjhl/S44/Preseason/SMJHL-PRE-17.html"))

doc.root.children.each do |item|
  if item.text.include? SLIP
    puts item
  end
end

def search_children(node)
  if has_children?(node)
    node.children.each do |child|
      search_children(child)
    end
  else
    print_slip_info(node)
  end
end

def has_children?(node)
  node.children.length > 0
end

def print_slip_info(node)
  slip = "Slip McScruff"
  if node.text.include? slip
    puts node.text
  end
end
