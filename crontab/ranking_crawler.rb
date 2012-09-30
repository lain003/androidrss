# -*- encoding: utf-8 -*-

require 'open-uri'
require 'hpricot'
require 'pry'
require 'rexml/document'
require 'openssl'
require "rss"

require "active_record"
require_relative "./../app/models/news"

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
$root_directory_path = File.expand_path(__FILE__)[0..File.expand_path(__FILE__).rindex("/")] + "../"

ActiveRecord::Base.establish_connection(    
  :adapter => "sqlite3",
  :database => $root_directory_path + "db/development.sqlite3",
  :pool => 5,
  :timeout => 5000
)

class RankingCrawler < ActiveRecord::Base
  def self.create_rss
    rank_in_apps = Hpricot(open("https://play.google.com/store/apps/collection/topselling_free")).search("ul.snippet-list li.goog-inline-block")
    
    rss = REXML::Document.new 
    rss << REXML::XMLDecl.new('1.0', 'UTF-8') 
    rss.add_element("rss", { "version"=>"2.0"})
    
    channel = REXML::Element.new("channel")
    channel.add_element("title").add_text "Android Ranking"
    channel.add_element("link").add_text "https://play.google.com/store/apps/collection/topselling_free"
    channel.add_element("description").add_text "AndroidのRankingのRSS"
    
    rank_in_apps.each do |rank_in_app|
      elem = rank_in_app.search("a.title").first
      item = channel.add_element("item")
      item.add_element("title").add_text elem["title"]
      item.add_element("link").add_text "https://play.google.com" + elem["href"]
      item.add_element("description").add_text rank_in_app.search("p.snippet-content").text
    end
    
    rss.elements["rss"].add_element(channel)

    output_file = File.open($root_directory_path + "public/android_rss.xml", "w")
    output_file.write(rss.to_s)
    output_file.close
  end
  
  def self.save_rss_to_db
    rss = RSS::Parser.parse("http://49.212.192.71/android_rss.xml")
    rss.items.map{ |rss_news|
      News.new(:title => rss_news.title, :url => rss_news.link,:description => rss_news.description).save
    }
  end
end

RankingCrawler.create_rss
RankingCrawler.save_rss_to_db