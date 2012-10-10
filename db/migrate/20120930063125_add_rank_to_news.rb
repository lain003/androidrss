class AddRankToNews < ActiveRecord::Migration
  def change
    add_column :news, :rank, :integer
  end
end
