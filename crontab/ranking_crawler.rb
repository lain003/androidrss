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
      item.add_element("description").add_text create_descriptiontext_contain_thumbnail(rank_in_app.search(".thumbnail img").first["src"],rank_in_app.search("p.snippet-content").text)
    end
    binding.pry
    rss.elements["rss"].add_element(channel)

    output_file = File.open($root_directory_path + "public/android_rss.xml", "w")
    output_file.write(rss.to_s)
    output_file.close
  end
  
  def self.save_rss_to_db
    rss = RSS::Parser.parse("public/android_rss.xml")
    last_ranking = Ranking.last
    ranking = Ranking.new(:genre => nil)
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

RankingCrawler.create_rss
RankingCrawler.save_rss_to_db