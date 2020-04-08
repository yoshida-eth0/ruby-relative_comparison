$LOAD_PATH << File.dirname(__FILE__) + "/../lib"

require 'relative_comparison'

alphabets = []
alphabets << [:a, :c, :e]
alphabets << [:a, :b, :d]
alphabets << [:c, :d, :e]
alphabets << [:e, :f]
alphabets << [:b, :c, :f]

pp RelativeComparison.merge(alphabets) {|a,b|
  puts "unknown order: #{a} #{b}"
  0
}
