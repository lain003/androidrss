class AddUrlToNews < ActiveRecord::Migration
  def change
    add_column :news, :url, :string
  end
end
