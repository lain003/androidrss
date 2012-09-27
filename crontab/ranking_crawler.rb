# -*- encoding: utf-8 -*-

require 'open-uri'
require 'hpricot'
require 'pry'
require 'rexml/document'

class RankingCrawler
  def self.search
    doc = Hpricot(open("https://play.google.com/store/apps/collection/topselling_free"))
    
    s = doc.search("ul.snippet-list li.goog-inline-block")
  end
  
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
      item.add_element("link").add_text "https://play.google.com/" + elem["href"]
      item.add_element("description").add_text rank_in_app.search("p.snippet-content").text
    end
    
    rss.elements["rss"].add_element(channel)
    
    output_file = File.open("../public/android_rss.xml", "w")
    output_file.write(rss.to_s)
    output_file.close
  end
end

#RankingCrawler.search
RankingCrawler.create_rss