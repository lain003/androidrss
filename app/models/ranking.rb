class Ranking < ActiveRecord::Base
  attr_accessible :genre
  
  has_many :news ,:dependent => :delete_all
end
