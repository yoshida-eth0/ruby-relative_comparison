$LOAD_PATH << File.dirname(__FILE__) + "/../lib"

require 'relative_comparison'

root = RelativeComparison::Root.new([
  ["グー", "チョキ"],
  ["チョキ", "パー"],
  ["パー", "グー"],
])

puts "グーからパーへの経路"
routes = root.traceroutes("グー", "パー")
routes.each {|route|
  puts "方向=#{route.direction}, 距離=#{route.metric}, 経路=#{route.nodes.map(&:value)}"
}
puts

left = root.node("グー")
10.times {
  right = left
  left = left.next_lefts.first
  puts "#{right.value}に勝つのは#{left.value}"
}

