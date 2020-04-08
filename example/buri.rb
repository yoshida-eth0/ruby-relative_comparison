$LOAD_PATH << File.dirname(__FILE__) + "/../lib"

require 'relative_comparison'

# http://jsnfri.fra.affrc.go.jp/kids/buri/kw6.html
a = []
a << ['アオコ', 'イナダ', 'ワラサ', 'ブリ']
a << ['ワカシ', 'イナダ', 'ワラサ', 'ブリ']
a << ['ワカナゴ', 'イナダ', 'ワラサ', 'ブリ']
a << ['ツバス', 'ハマチ', 'メジロ', 'ブリ']
a << ['ツバイソ', 'フクラギ', 'ガンド', 'ブリ']
a << ['コゾクラ', 'フクラギ', 'ガンド', 'ブリ']
a << ['ツバス', 'ハマチ', 'マルゴ', 'ブリ']
a << ['ツバス', 'ヤズ', 'ワラサ', 'ブリ']


def print_prev_names(node)
  lefts = node.next_lefts
  return if lefts.length==0

  puts "#{node.value}のひとつ前の名前は#{lefts.length}個"
  p lefts.map(&:value)
  puts

  lefts.each {|left|
    print_prev_names(left)
  }
end


root = RelativeComparison::Root.new(a)

node = root.node('ブリ')
print_prev_names(node)
puts


puts "ツバスからブリへの経路"
root.traceroutes('ツバス', 'ブリ').each {|route|
  p route.nodes.map(&:value)
}
