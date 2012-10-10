class AddChangeRankToNews < ActiveRecord::Migration
  def change
    add_column :news, :change_rank, :integer
  end
end
