class RemoveBodyFromNews < ActiveRecord::Migration
  def up
    remove_column :news, :body
  end

  def down
    add_column :news, :body, :string
  end
end
