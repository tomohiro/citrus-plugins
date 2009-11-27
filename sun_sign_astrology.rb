require 'nkf'

require "open-uri"
require 'hpricot'

class SunSignAstrology < Citrus::Plugin
  def initialize(*args)
    super
    @suffix = @config['suffix'] || 'の運勢教えて'
  end

  def on_privmsg(prefix, channel, message)
    case message
    when /^(.+)#{@suffix}$/
      result = search_sign($1)

      if result.empty?
        notice(channel, '／(^o^)＼ わかにゃいっ') 
      else 
        notice(channel, result.to_s) 
      end
    end
  end

  private

  def search_sign(sign)
    ranking = get_ranking 'http://fortune.yahoo.co.jp/12astro/ranking.html'
    result = ''

    ranking.each do |rank|
      if rank[:name] == sign
        result = "#{rank[:name]} #{rank[:rank]} #{rank[:desc]}！だよ♪  (#{rank[:link]})"
      end
    end
    result
  end

  def get_ranking(uri)
    begin
      doc = Hpricot(open(uri))

      names = doc/'td/p/img'
      ranks = doc/'td/img'
      descs = doc/'p.ft01/a'

      ranking = []
      names.each_with_index do |name, desc_counter|
        rank_counter = desc_counter + 1
        ranking << {
          :name => name.attributes['alt'].to_u8,
          :rank => ranks[rank_counter].attributes['alt'].to_u8,
          :desc => descs[desc_counter].inner_text.to_u8,
          :link => descs[desc_counter].attributes['href']
        }
      end

      ranking
    rescue
      '／(^o^)＼ こわれたっ'
    end
  end
end
