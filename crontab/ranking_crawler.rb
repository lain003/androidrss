# -*- encoding: utf-8 -*-

require 'open-uri'
require 'hpricot'
require 'pry'
require 'rexml/document'
require 'openssl'
require "rss"

require "active_record"
require_relative "./../app/models/news"
require_relative "./../app/models/ranking.rb"

TOPSELLING_FREE = "topselling_free"
TOPSELLING_PAID = "topselling_paid"

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
$root_directory_path = File.expand_path(__FILE__)[0..File.expand_path(__FILE__).rindex("/")] + "../"

ActiveRecord::Base.establish_connection(    
  :adapter => "sqlite3",
  :database => $root_directory_path + "db/development.sqlite3",
  :pool => 5,
  :timeout => 5000
)

class RankingCrawler < ActiveRecord::Base
  def self.create_rss(ranking_type)
    playranking_url = "https://play.google.com/store/apps/collection/"
    if ranking_type == TOPSELLING_FREE
      playranking_url += "topselling_free"
      channel_description_text = "Androidの無料のRankingのRSS"
      rss_file_name = "topselling_free_rss.xml"
    elsif ranking_type == TOPSELLING_PAID
      playranking_url += "topselling_paid"
      channel_description_text = "Androidの有料のRankingのRSS"
      rss_file_name = "topselling_paid_rss.xml"
    elsif
      p "ERROR:Unknown ranking_type"
      return -1
    end
    rank_in_apps = Hpricot(open(playranking_url)).search("ul.snippet-list li.goog-inline-block")
    
    rss = REXML::Document.new 
    rss << REXML::XMLDecl.new('1.0', 'UTF-8') 
    rss.add_element("rss", { "version"=>"2.0"})
    
    channel = REXML::Element.new("channel")
    channel.add_element("title").add_text "Android Ranking"
    channel.add_element("link").add_text playranking_url
    channel.add_element("description").add_text channel_description_text
    
    rank_in_apps.each do |rank_in_app|
      elem = rank_in_app.search("a.title").first
      item = channel.add_element("item")
      item.add_element("title").add_text elem["title"]
      item.add_element("link").add_text "https://play.google.com" + elem["href"]
      item.add_element("description").add_text create_descriptiontext_contain_thumbnail(rank_in_app.search(".thumbnail img").first["src"],rank_in_app.search("p.snippet-content").text)
    end
    rss.elements["rss"].add_element(channel)

    output_file = File.open($root_directory_path + "public/" + rss_file_name, "w")
    output_file.write(rss.to_s)
    output_file.close
  end
  
  def self.save_rss_to_db(ranking_type)
    if ranking_type == TOPSELLING_FREE
      rss_file_name = "topselling_free_rss.xml"
      genre_name = "topselling_free"
    elsif ranking_type == TOPSELLING_PAID
      rss_file_name = "topselling_paid_rss.xml"
      genre_name = "topselling_paid"
    else
      p "ERROR:Unknown ranking_type"
      return -1
    end
    
    rss = RSS::Parser.parse("public/" + rss_file_name)
    last_ranking = Ranking.last
    ranking = Ranking.new(:genre => genre_name)
    rank = 1
    rss.items.map{ |rss_news|
      hpri_description = Hpricot(rss_news.description)
      news = News.new(:title => rss_news.title, :url => rss_news.link,:description => hpri_description.search("p.description").first.inner_text,\
      :rank => rank,:thumbnail_url => hpri_description.search("p.thumbnail img").first["src"],:last_ranking => last_ranking)
      ranking.news << news
      news.save
      rank += 1
    }
    ranking.save
  end
  
  private
  def self.create_descriptiontext_contain_thumbnail(thumbnail_src,description)
    thumbnail_tag = '<p class="thumbnail">' + '<img alt="noimage" height="70" width="94" src=' + thumbnail_src +'>' +'<p>'
    description_tag = '<p class="description">' + description + '</p>'
    return "![CDATA[" + thumbnail_tag + description_tag + "]]"
  end
  private_class_method :create_descriptiontext_contain_thumbnail
end

RankingCrawler.create_rss(TOPSELLING_FREE)
RankingCrawler.save_rss_to_db(TOPSELLING_FREE)
RankingCrawler.create_rss(TOPSELLING_PAID)
RankingCrawler.save_rss_to_db(TOPSELLING_PAID)