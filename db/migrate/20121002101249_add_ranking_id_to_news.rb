class AddRankingIdToNews < ActiveRecord::Migration
  def change
    add_column :news, :ranking_id, :integer
  end
end
