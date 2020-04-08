$LOAD_PATH << File.dirname(__FILE__) + "/../lib"

require 'relative_comparison'

root = RelativeComparison::Root.new([
  ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥', '子']
])

src = '卯'
dst = '申'

left_route = root.left_traceroutes(src, dst).first
right_route = root.right_traceroutes(src, dst).first
shortest_route = root.shortest_routes(src, dst).first

puts "#{src}年を基準に前の#{dst}年は、#{left_route.metric}年前"
puts "#{src}年を基準に次の#{dst}年は、#{right_route.metric}年後"

sign = shortest_route.direction==:left ? '前' : '後'
puts "#{src}年を基準に一番近い#{dst}年は、#{shortest_route.metric}年#{sign}"
