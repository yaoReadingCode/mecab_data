require 'mecab'
require 'pg'
require 'pp'

  def parse_noun(word)

    mecab = MeCab::Tagger.new("-d /usr/local/Cellar/mecab/0.996/lib/mecab/dic/mecab-ipadic-neologd")
    node = mecab.parseToNode(word)

    nouns = []
    while node

        if /^名詞/ =~ node.feature.split(/,/)[0] then
       	   nouns.push(node.surface)
       	end
        
        node = node.next
    end

    return nouns
  end

  begin
    connection = PG::connect(:host => "localhost", :user => "dse", :dbname => "ruby_sample", :port => "5432")
    connection.internal_encoding = "UTF-8"
    
    puts "connected"
    
    #connection.exec("DROP TABLE keyword;")
    #connection.exec("CREATE TABLE keyword (id SERIAL PRIMARY KEY, word varchar(20) UNIQUE NOT NULL, count int);")
    
    words = []
    words_and_count = []
    
    words = parse_noun("サンプル文章です。この文章をサンプルして出力します。2015年")
    
    #wordsから名詞を抽出し、名詞と頻度をwords_and_countに追加
    words.uniq.map do |word|
      words_and_count[words_and_count.size] = ["#{word}", "#{words.grep(word).count}"] if word
    end
    
    #それぞれの名詞をデータベースに挿入していく
    words_and_count.each do |x|
      begin
        words = x[0]
        counts = Integer(x[1])
        connection.exec("INSERT INTO keyword values (nextval('keyword_id_seq'), '#{words}', #{counts});") #count はカラム名　countsは変数
      #Unique Violationが発生した時は、countに追加で値をいれてゆく
      rescue PG::UniqueViolation 
        select = connection.exec("SELECT word,count FROM keyword WHERE word = '#{words}';")
      	select.each do |tuple|
      	  counts = counts + tuple["count"].to_i
        end
        connection.exec("UPDATE keyword SET count = '#{counts}' WHERE word ='#{words}';")
        next
      end
    end
    
  	select = connection.exec("SELECT * FROM keyword;")
  	select.each do |tuple|
  	  puts tuple['id'].to_s + ":" + tuple["word"] + ":" + tuple["count"]
  	end
    
    #pp words_and_count.sort_by { |words_and_count| words_and_count[1].to_i }.reverse
    
  ensure
    connection.finish
    puts "disconnected"
  end