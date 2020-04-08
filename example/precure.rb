$LOAD_PATH << File.dirname(__FILE__) + "/../lib"

require 'relative_comparison'

precure = []
precure << ['ふたりはプリキュア', 'ふたりはプリキュアMax Heart', 'ふたりはプリキュアSplash Star', 'Yes!プリキュア5']
precure << ['Yes!プリキュア5', 'Yes!プリキュア5GoGo!', 'フレッシュプリキュア!', 'ハートキャッチプリキュア!']
precure << ['フレッシュプリキュア!', 'ハートキャッチプリキュア!', 'スイートプリキュア♪']
precure << ['スイートプリキュア♪', 'スマイルプリキュア!', 'ドキドキ!プリキュア']
precure << ['ドキドキ!プリキュア', 'ハピネスチャージプリキュア!']
precure << ['ハピネスチャージプリキュア!', 'Go!プリンセスプリキュア', '魔法つかいプリキュア!']
precure << ['魔法つかいプリキュア!', 'キラキラ☆プリキュアアラモード']
precure << ['キラキラ☆プリキュアアラモード', 'HUGっと!プリキュア', 'スター☆トゥインクルプリキュア']
precure << ['スター☆トゥインクルプリキュア', 'ヒーリングっど♥プリキュア']
precure << ['Yes!プリキュア5GoGo!', 'aaa', 'ハートキャッチプリキュア!']

pp RelativeComparison.merge(precure) {|a,b|
  puts "unknown order: #{a} #{b}"
  0
}
