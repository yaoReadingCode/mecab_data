require 'csv'
require 'natto'
require 'pp'

reader = CSV.open('tweets.csv', 'r')
reader.take 1

nm = Natto::MeCab.new("-d /usr/local/Cellar/mecab/0.996/lib/mecab/dic/mecab-ipadic-neologd")
t_map = {}
reader.each do |row|
  next if row[5].index('RT') == 0
  nm.parse(row[5]) do |n|
    t_map[n.surface] = t_map[n.surface] ? t_map[n.surface] + 1 : 1 if n.feature.match("名詞")
  end
end

t_map = t_map.sort_by {|k, v| v}.reverse

File.open('t.csv','w'){|f|
  t_map.each do |word, count|
    f.write "#{word},#{count}\n"
  end
}