require 'csv'
require 'mecab'
require 'pp'

def parse_noun(word)

  mecab = MeCab::Tagger.new("-d /usr/local/Cellar/mecab/0.996/lib/mecab/dic/mecab-ipadic-neologd")
  node = mecab.parseToNode(word)

  nouns = {}
  while node

      if /^名詞/ =~ node.feature.split(/,/)[0] then
     	   nouns[node.surface] = nouns[node.surface] ? nouns[node.surface] + 1 : 1
     	end
      #pp nouns
      node = node.next
  end

  return nouns
end

reader = CSV.open('tweets.csv', 'r')
reader.take 1


words_and_count = {}

reader.each do |row|
  next if row[5].index('RT') == 0
  words_and_count = parse_noun(row[5])
end

words_and_count = words_and_count.sort_by {|k, v| v}.reverse

File.open('t.csv', 'w'){|f|
  words_and_count.each do |word, count|
    f.write("#{word}, #{count}" + "\n")
  end
}

