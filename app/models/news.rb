class News < ActiveRecord::Base
  attr_accessible :description, :title,:url,:rank,:ranking_id,:change_rank,:thumbnail_url
  
  belongs_to :ranking
  
  def initialize(hash)
    super
    self.calculates_change_ranking(hash[:last_ranking])
  end
  
  def get_changerank_icon
    if change_rank == nil
      return "rank_new.gif"
    elsif change_rank > 0
      return "rank_down.gif"
    elsif change_rank == 0
      return "rank_even.gif"
    elsif change_rank < 0
      return "rank_up.gif"
    end
  end
  
  def calculates_change_ranking(last_ranking)
    if last_ranking
      last_news = last_ranking.news.find_by_url(self.url)
      if last_news
        self.change_rank = rank - last_news.rank
      else
        self.change_rank = nil
      end
    else
      self.change_rank = nil
    end
  end
end
