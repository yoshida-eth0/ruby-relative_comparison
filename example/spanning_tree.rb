$LOAD_PATH << File.dirname(__FILE__) + "/../lib"

require 'relative_comparison'

def regist_bi(root, left, right, metric)
  root.regist_pair(left, right, metric: metric)
  root.regist_pair(right, left, metric: metric)
end


root = RelativeComparison::Root.new

regist_bi(root, :left_node, :top_node, 5)
regist_bi(root, :left_node, :center_node, 4)
regist_bi(root, :left_node, :left_bottom_node, 2)
regist_bi(root, :top_node, :center_node, 2)
regist_bi(root, :top_node, :right_node, 6)
regist_bi(root, :center_node, :left_bottom_node, 3)
regist_bi(root, :center_node, :right_bottom_node, 2)
regist_bi(root, :left_bottom_node, :right_bottom_node, 6)
regist_bi(root, :right_bottom_node, :right_node, 4)


shortest_route = root.shortest_routes(:left_node, :right_node).first

puts "hop count: #{shortest_route.hop_count}"
puts "total metric: #{shortest_route.metric}"
puts

puts "routes (metric)"
puts shortest_route.map {|hop|
  "#{hop.node.value} (#{hop.metric})"
}.join(" => ")
