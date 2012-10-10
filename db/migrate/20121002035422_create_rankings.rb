class CreateRankings < ActiveRecord::Migration
  def change
    create_table :rankings do |t|
      t.string :genre

      t.timestamps
    end
  end
end
